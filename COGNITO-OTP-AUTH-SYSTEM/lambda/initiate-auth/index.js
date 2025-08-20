const {
    CognitoIdentityProviderClient,
    AdminCreateUserCommand,
    AdminInitiateAuthCommand,
    AdminSetUserPasswordCommand,
    AdminGetUserCommand
} = require('@aws-sdk/client-cognito-identity-provider');

const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const {
    DynamoDBDocumentClient,
    PutCommand
} = require('@aws-sdk/lib-dynamodb');

const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

const cognitoClient = new CognitoIdentityProviderClient();
const dynamoClient = new DynamoDBClient();
const docClient = DynamoDBDocumentClient.from(dynamoClient);
const sesClient = new SESClient();

const formatResponse = (statusCode, body) => {
    const response = {
        statusCode,
        headers: {
            'Access-Control-Allow-Origin': '*',//Restrict this to your frontend domain in production
            'Access-Control-Allow-Headers': 'Content-Type,Authorization',
            'Access-Control-Allow-Methods': 'POST,OPTIONS',
            'Access-Control-Allow-Credentials': true,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
    };
    console.log('Sending response:', JSON.stringify(response, null, 2));
    return response;
};

exports.handler = async (event) => {
    console.log('Event received:', JSON.stringify(event, null, 2));

    try {
        let body;
        try {
            body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
        } catch (parseError) {
            return formatResponse(400, { message: 'Invalid JSON in request body' });
        }

        if (!body?.email) {
            return formatResponse(400, { message: 'Email is required' });
        }

        const { email } = body;
        const normalizedEmail = email.toLowerCase();
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Check if user exists and get their status
        let userExists = false;
        let userStatus = '';
        try {
            const userResponse = await cognitoClient.send(new AdminGetUserCommand({
                UserPoolId: process.env.USER_POOL_ID,
                Username: normalizedEmail
            }));
            userExists = true;
            userStatus = userResponse.UserStatus;
            console.log('User status:', userStatus);
        } catch (error) {
            if (error.name !== 'UserNotFoundException') {
                throw error;
            }
            console.log('User does not exist, will create new user');
        }

        // Store OTP in DynamoDB
        try {
            await docClient.send(new PutCommand({
                TableName: process.env.OTP_TABLE,
                Item: {
                    email: normalizedEmail,
                    otp: otp,
                    ttl: Math.floor(Date.now() / 1000) + 300 // 5 minutes
                }
            }));
            console.log('OTP stored successfully');
        } catch (dbError) {
            console.error('DynamoDB error:', dbError);
            return formatResponse(500, { message: 'Failed to store OTP' });
        }

        // Send OTP via SES
        try {
            const emailParams = {
                Source: process.env.FROM_EMAIL,
                Destination: {
                    ToAddresses: [normalizedEmail]
                },
                Message: {
                    Subject: {
                        Data: 'Your Verification Code'
                    },
                    Body: {
                        Text: {
                            Data: `Your verification code is: ${otp}\n\nThis code will expire in 5 minutes.`
                        },
                        Html: {
                            Data: `
                                <h2>Your Verification Code</h2>
                                <p>Your verification code is: <strong>${otp}</strong></p>
                                <p>This code will expire in 5 minutes.</p>
                            `
                        }
                    }
                }
            };

            await sesClient.send(new SendEmailCommand(emailParams));
            console.log('Email sent successfully via SES');
        } catch (emailError) {
            console.error('SES email error:', emailError);
            return formatResponse(500, {
                message: 'Failed to send verification email',
                error: emailError.message
            });
        }

        // Handle user creation or password reset based on status
        if (!userExists) {
            try {
                const createUserParams = {
                    UserPoolId: process.env.USER_POOL_ID,
                    Username: normalizedEmail,
                    TemporaryPassword: otp,
                    MessageAction: 'SUPPRESS', // Don't send Cognito email since SES is being used
                    UserAttributes: [
                        {
                            Name: 'email',
                            Value: normalizedEmail
                        },
                        {
                            Name: 'email_verified',
                            Value: 'true'
                        }
                    ]
                };

                console.log('Creating user with params:', JSON.stringify(createUserParams, null, 2));
                await cognitoClient.send(new AdminCreateUserCommand(createUserParams));
                console.log('User created successfully');
            } catch (error) {
                console.error('Create user error:', error);
                return formatResponse(500, {
                    message: 'Failed to create user',
                    error: error.message
                });
            }
        } else {
            try {
                await cognitoClient.send(new AdminSetUserPasswordCommand({
                    UserPoolId: process.env.USER_POOL_ID,
                    Username: normalizedEmail,
                    Password: otp,
                    Permanent: false
                }));
                console.log('Password reset successfully');
            } catch (error) {
                console.error('Password reset error:', error);
                return formatResponse(400, {
                    message: 'Failed to reset password',
                    error: error.message,
                    success: false
                });
            }
        }

        // Initiate auth
        try {
            const authParams = {
                UserPoolId: process.env.USER_POOL_ID,
                ClientId: process.env.CLIENT_ID,
                AuthFlow: 'ADMIN_USER_PASSWORD_AUTH',
                AuthParameters: {
                    USERNAME: normalizedEmail,
                    PASSWORD: otp
                }
            };

            console.log('Initiating auth with params:', JSON.stringify(authParams, null, 2));

            const authResponse = await cognitoClient.send(
                new AdminInitiateAuthCommand(authParams)
            );

            console.log('Auth response:', JSON.stringify(authResponse, null, 2));

            return formatResponse(200, {
                message: 'OTP sent successfully to your email',
                session: authResponse.Session,
                challengeName: authResponse.ChallengeName,
                email: normalizedEmail,
                isNewUser: !userExists,
                success: true
            });

        } catch (authError) {
            console.error('Auth error:', authError);
            return formatResponse(500, {
                message: 'Authentication failed',
                error: authError.message,
                success: false
            });
        }
    } catch (error) {
        console.error('Unhandled error:', error);
        return formatResponse(500, {
            message: 'Internal server error',
            error: error.message,
            success: false
        });
    }
};

