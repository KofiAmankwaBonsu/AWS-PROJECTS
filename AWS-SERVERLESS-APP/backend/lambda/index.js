const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand, PutCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const dynamoDB = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.TABLE_NAME;

// Define CORS headers
const headers = {
    "Access-Control-Allow-Origin": "*", // Replace with your S3 website URL in production
    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Credentials": false,
    "Content-Type": "application/json"
};

exports.handler = async (event) => {
    try {
        console.log('Event:', JSON.stringify(event, null, 2));
        console.log('TABLE_NAME:', TABLE_NAME);

        if (!TABLE_NAME) {
            throw new Error('TABLE_NAME environment variable is not set');
        }

        // Handle OPTIONS request for CORS preflight
        if (event.requestContext?.http?.method === 'OPTIONS' || event.httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers,
                body: ''
            };
        }

        // Get the HTTP method from either API Gateway v1 or v2 event format
        const httpMethod = event.requestContext?.http?.method || event.httpMethod;

        // Handle GET request for fetching trucks
        if (httpMethod === 'GET') {
            const command = new ScanCommand({
                TableName: TABLE_NAME
            });

            const result = await dynamoDB.send(command);
            console.log('DynamoDB Response:', JSON.stringify(result, null, 2));

            return {
                statusCode: 200,
                headers,
                body: JSON.stringify(result.Items || [])
            };
        }

        // Handle POST request for adding trucks
        if (httpMethod === 'POST') {
            // Ensure there's a body in the request
            if (!event.body) {
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({
                        message: 'Missing request body'
                    })
                };
            }

            let item;
            try {
                item = JSON.parse(event.body);
            } catch (e) {
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({
                        message: 'Invalid JSON in request body'
                    })
                };
            }

            // Validate required fields
            const requiredFields = ['id', 'driver', 'route', 'status'];
            const missingFields = requiredFields.filter(field => !item[field]);

            if (missingFields.length > 0) {
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({
                        message: `Missing required fields: ${missingFields.join(', ')}`
                    })
                };
            }

            // Add timestamp if not provided
            if (!item.lastUpdated) {
                item.lastUpdated = new Date().toISOString();
            }

            const command = new PutCommand({
                TableName: TABLE_NAME,
                Item: item
            });

            await dynamoDB.send(command);
            return {
                statusCode: 201,
                headers,
                body: JSON.stringify({
                    message: 'Truck added successfully',
                    truck: item
                })
            };
        }

        // If we get here, and the HTTP method is not supported
        return {
            statusCode: 400,
            headers,
            body: JSON.stringify({
                message: 'Unsupported method',
                supportedMethods: ['GET', 'POST', 'OPTIONS']
            })
        };

    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
                message: 'Internal server error',
                error: error.message
            })
        };
    }
};
