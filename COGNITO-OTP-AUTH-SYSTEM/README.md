# AWS Cognito OTP Authentication System

A serverless passwordless authentication system using AWS Cognito, Lambda, DynamoDB, and SES with OTP-based email verification.

## Architecture

- **AWS Cognito**: User pool management and JWT token generation
- **Lambda Functions**: OTP generation/validation and authentication flow
- **DynamoDB**: OTP storage with TTL (5-minute expiration)
- **SES**: Email delivery for OTP codes
- **API Gateway**: REST API endpoints for frontend integration
- **S3**: Static website hosting for frontend

## Features

- ✅ Passwordless authentication with email OTP
- ✅ 6-digit OTP codes with 5-minute expiration
- ✅ JWT token management (Access, ID, Refresh tokens)
- ✅ Responsive web interface
- ✅ CORS-enabled API endpoints
- ✅ Automatic user creation and management
- ✅ Session storage for secure token handling

## Project Structure

```
awscognito/
├── main.tf              # Core AWS infrastructure
├── variables.tf         # Terraform variables
├── outputs.tf          # Terraform outputs
├── api.tf              # API Gateway configuration
├── s3.tf               # S3 bucket for frontend hosting
├── backend.tf          # Terraform state backend
├── providers.tf        # AWS provider configuration
├── terraform.tfvars    # Environment-specific variables
├── lambda/
│   ├── initiate-auth/
│   │   └── index.js    # OTP generation Lambda
│   └── verify-otp/
│       └── index.js    # OTP verification Lambda
└── frontend/
    ├── index.html      # Login page
    ├── home.html       # Protected page
    ├── auth.js         # Authentication logic
    ├── styles.css      # UI styling
    └── config.js       # API configuration
```

## Setup Instructions

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Verified SES email address

### 1. Configure Variables

Update `terraform.tfvars`:
```hcl
user_pool_id = "your-cognito-user-pool-id"
client_id = "your-cognito-client-id"
from_email = "your-verified-ses-email@domain.com"
```

### 2. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 3. Update Frontend Configuration

After deployment, update `frontend/config.js` with the API Gateway endpoint, cognito user pool and client id from Terraform outputs.

## API Endpoints

### POST /initiate-auth
Generates and sends OTP to user's email.

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "message": "OTP sent successfully to your email",
  "session": "session-token",
  "challengeName": "NEW_PASSWORD_REQUIRED",
  "success": true
}
```

### POST /verify-otp
Validates OTP and returns JWT tokens.

**Request:**
```json
{
  "email": "user@example.com",
  "otp": "123456",
  "session": "session-token"
}
```

**Response:**
```json
{
  "message": "Authentication successful",
  "success": true,
  "tokens": {
    "accessToken": "jwt-access-token",
    "idToken": "jwt-id-token",
    "refreshToken": "jwt-refresh-token"
  }
}
```

## Authentication Flow

1. User enters email address
2. System generates 6-digit OTP and stores in DynamoDB
3. OTP sent via SES email
4. User enters OTP code
5. System validates OTP and completes Cognito authentication
6. JWT tokens returned to frontend
7. Tokens stored in browser sessionStorage/localStorage

## Token Management

- **Access Token**: API authentication (1 hour expiry)
- **ID Token**: User information (1 hour expiry)
- **Refresh Token**: Token renewal (30 days expiry)

## Security Features

- OTP expires after 5 minutes
- Tokens are domain-specific and cannot be used across applications
- CORS protection for API endpoints
- Automatic cleanup of expired OTP records via DynamoDB TTL

## Monitoring

CloudWatch automatically captures:
- Lambda function logs and metrics
- API Gateway request/response logs
- DynamoDB operation metrics
- SES email delivery status

## Known Issues

- SES emails may go to spam folder without domain authentication
- Production deployment requires custom domain with SPF/DKIM/DMARC records

## Cost Optimization

- DynamoDB uses on-demand billing
- Lambda functions use ARM64 architecture for cost efficiency
- S3 bucket configured for static website hosting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request
