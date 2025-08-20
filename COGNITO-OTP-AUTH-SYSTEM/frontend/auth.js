import config from './config.js';

class Auth {
    constructor() {
        this.config = config;
        this.init();
    }

    init() {
        this.authForm = document.getElementById('authForm');
        this.otpForm = document.getElementById('otpForm');
        this.resendButton = document.getElementById('resendOtp');
        
        if (this.authForm) {
            this.authForm.addEventListener('submit', (e) => this.handleSubmit(e));
        }
        
        if (this.otpForm) {
            this.otpForm.addEventListener('submit', (e) => this.handleOtpSubmit(e));
            this.setupOtpInputs();
        }

        if (this.resendButton) {
            this.resendButton.addEventListener('click', () => this.handleResendOtp());
        }
    }

    setupOtpInputs() {
        const inputs = document.querySelectorAll('.otp-input');
        inputs.forEach((input, index) => {
            input.addEventListener('keyup', (e) => {
                if (e.key >= 0 && e.key <= 9) {
                    if (index < inputs.length - 1) {
                        inputs[index + 1].focus();
                    }
                } else if (e.key === 'Backspace') {
                    if (index > 0) {
                        inputs[index - 1].focus();
                    }
                }
            });
        });
    }

    showOtpForm(email) {
        this.authForm.style.display = 'none';
        this.otpForm.style.display = 'block';
        this.currentEmail = email; // Store email for resend functionality
    }

    async handleSubmit(e) {
        e.preventDefault();
        const email = document.getElementById('email').value;
        
        try {
            const result = await this.initiateAuth(email);
            if (result.session) {
                this.currentSession = result.session;
                this.showOtpForm(email);
            }
        } catch (error) {
            this.showError(error.message);
        }
    }

    async handleOtpSubmit(e) {
        e.preventDefault();
        const inputs = document.querySelectorAll('.otp-input');
        const otp = Array.from(inputs).map(input => input.value).join('');
        
        try {
            await this.verifyOtp(this.currentEmail, otp, this.currentSession);
        } catch (error) {
            this.showError(error.message);
        }
    }

    async handleResendOtp() {
        if (this.currentEmail) {
            try {
                await this.initiateAuth(this.currentEmail);
                this.showSuccess('New code sent successfully');
            } catch (error) {
                this.showError(error.message);
            }
        }
    }

    showError(message) {
        Swal.fire({
            icon: 'error',
            title: 'Error',
            text: message
        });
    }

    showSuccess(message) {
        Swal.fire({
            icon: 'success',
            title: 'Success',
            text: message,
            timer: 2000,
            showConfirmButton: false
        });
    }

    async initiateAuth(email) {
        try {
            console.log('Sending request with email:', email); // Debug log
            
            const response = await fetch(`${this.config.apiEndpoint}/auth/initiate`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 
                    email: email
                })
            });
    
            console.log('Response status:', response.status); // Debug log
            
            const data = await response.json();
            console.log('Response data:', data); // Debug log
    
            if (!response.ok) {
                throw new Error(data.message || 'Failed to initiate authentication');
            }
    
            return data;
        } catch (error) {
            console.error('Auth error:', {
                message: error.message,
                stack: error.stack
            });
            throw error;
        }
    }
    
    async showOtpInput(email, session) {
        const { value: otp } = await Swal.fire({
            title: 'Enter OTP',
            text: 'Check your email for the verification code',
            input: 'text',
            inputAttributes: {
                autocapitalize: 'off',
                maxlength: 6
            },
            showCancelButton: true,
            confirmButtonText: 'Verify',
            showLoaderOnConfirm: true,
            allowOutsideClick: () => !Swal.isLoading()
        });

        if (otp) {
            try {
                await this.verifyOtp(email, otp, session);
            } catch (error) {
                this.showError(error.message);
            }
        }
    }

    async verifyOtp(email, otp, session) {
        try {
            const response = await fetch(`${this.config.apiEndpoint}/auth/verify`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    email,
                    otp,
                    session
                })
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.message || 'Verification failed');
            }

            if (data.success) {
                // Store authentication data in session storage
                sessionStorage.setItem('authData', JSON.stringify({
                    isAuthenticated: true,
                    email: email,
                    timestamp: new Date().toISOString()
                }));
    
                // If your API returns tokens, store them too
                if (data.tokens) {
                    sessionStorage.setItem('tokens', JSON.stringify(data.tokens));
                }
                
                await Swal.fire({
                    icon: 'success',
                    title: 'Verified!',
                    text: 'Authentication successful'
                });
                // Handle successful verification (e.g., redirect to dashboard)
                window.location.href = '/home.html';
            }
        } catch (error) {
            console.error('Verification error:', error);
            throw error;
        }
    }

    showError(message) {
        Swal.fire({
            icon: 'error',
            title: 'Error',
            text: message
        });
    }

    handleAuthSuccess(tokens) {
        // Store tokens securely
        sessionStorage.setItem('accessToken', tokens.AccessToken);
        sessionStorage.setItem('idToken', tokens.IdToken);
        sessionStorage.setItem('refreshToken', tokens.RefreshToken);

        Swal.fire({
            icon: 'success',
            title: 'Successfully authenticated!',
            showConfirmButton: false,
            timer: 1500
        }).then(() => {
            window.location.href = '/home.html';
        });
    }

    showError(message) {
        Swal.fire({
            icon: 'error',
            title: 'Error',
            text: message
        });
    }

    // Utility method to check if user is authenticated
    isAuthenticated() {
        return !!sessionStorage.getItem('accessToken');
    }

    // Utility method to get the current user's token
    getToken() {
        return sessionStorage.getItem('accessToken');
    }

}

export default Auth;
