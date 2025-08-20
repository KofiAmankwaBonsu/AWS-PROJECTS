const { 
    CognitoIdentityProviderClient,
    AdminRespondToAuthChallengeCommand
} = require('@aws-sdk/client-cognito-identity-provider');

const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { 
    DynamoDBDocumentClient, 
    GetCommand,
    DeleteCommand 
} = require('@aws-sdk/lib-dynamodb');

const cognitoClient = new CognitoIdentityProviderClient();
const dynamoClient = new DynamoDBClient();
const docClient = DynamoDBDocumentClient.from(dynamoClient);

exports.handler = async (event) => {
    try {
        console.log('Raw event:', JSON.stringify(event, null, 2));
        
        const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
        
        if (!body || !body.email || !body.otp || !body.session) {
            return {
                statusCode: 400,
                headers: {
                    'Access-Control-Allow-Origin': '*', //Restrict this to your frontend domain in production
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'POST,OPTIONS',
                    'Access-Control-Allow-Credentials': true,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: 'Email, OTP, and session are required'
                })
            };
        }

        const { email, otp, session } = body;

        // 1. Verify OTP from DynamoDB
        const getResult = await docClient.send(new GetCommand({
            TableName: process.env.OTP_TABLE,
            Key: { email: email.toLowerCase() }
        }));

        if (!getResult.Item || getResult.Item.otp !== otp) {
            return {
                statusCode: 400,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'POST,OPTIONS',
                    'Access-Control-Allow-Credentials': true,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: 'Invalid or expired OTP'
                })
            };
        }

        // 2. Complete the authentication challenge
        try {
            const authResult = await cognitoClient.send(new AdminRespondToAuthChallengeCommand({
                UserPoolId: process.env.USER_POOL_ID,
                ClientId: process.env.CLIENT_ID,
                ChallengeName: 'NEW_PASSWORD_REQUIRED',
                ChallengeResponses: {
                    USERNAME: email.toLowerCase(),
                    NEW_PASSWORD: otp
                },
                Session: session
            }));

            // 3. Delete the used OTP
            await docClient.send(new DeleteCommand({
                TableName: process.env.OTP_TABLE,
                Key: { email: email.toLowerCase() }
            }));

            return {
                statusCode: 200,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'POST,OPTIONS',
                    'Access-Control-Allow-Credentials': true,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: 'Authentication successful',
                    success: true,
                    tokens: {
                        accessToken: authResult.AuthenticationResult.AccessToken,
                        idToken: authResult.AuthenticationResult.IdToken,
                        refreshToken: authResult.AuthenticationResult.RefreshToken
                    }
                })
            };

        } catch (authError) {
            console.error('Auth error:', authError);
            
            return {
                statusCode: 400,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'POST,OPTIONS',
                    'Access-Control-Allow-Credentials': true,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: 'Session expired or invalid. Please request a new OTP.',
                    error: authError.message
                })
            };
        }

    } catch (error) {
        console.error('Lambda error:', error);
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Access-Control-Allow-Methods': 'POST,OPTIONS',
                'Access-Control-Allow-Credentials': true,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: 'Internal server error',
                error: error.message
            })
        };
    }
};