const { TranslateClient, TranslateTextCommand } = require('@aws-sdk/client-translate');
const client = new TranslateClient();

// Comprehensive CORS headers
const corsHeaders = {
    'Access-Control-Allow-Origin': '*', //Restrict in production
    'Access-Control-Allow-Headers': 'Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Max-Age': '86400',
    'Content-Type': 'application/json'
};

exports.handler = async (event) => {
    console.log('Event received:', JSON.stringify(event, null, 2));

    // Handle preflight OPTIONS request
    if (event.httpMethod === 'OPTIONS') {
        console.log('Handling OPTIONS request');
        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify({ message: 'CORS preflight' })
        };
    }

    // Handle POST request
    if (event.httpMethod === 'POST') {
        console.log('Handling POST request');
        try {
            const { text, sourceLanguage, targetLanguage } = JSON.parse(event.body);
            console.log('Parsed request:', { text, sourceLanguage, targetLanguage });

            const command = new TranslateTextCommand({
                Text: text,
                SourceLanguageCode: sourceLanguage,
                TargetLanguageCode: targetLanguage
            });

            console.log('Calling AWS Translate...');
            const result = await client.send(command);
            console.log('Translation result:', result);

            return {
                statusCode: 200,
                headers: corsHeaders,
                body: JSON.stringify({
                    translatedText: result.TranslatedText,
                    sourceLanguage: result.SourceLanguageCode,
                    targetLanguage: result.TargetLanguageCode
                })
            };
        } catch (error) {
            console.error('Translation error:', error);
            return {
                statusCode: 500,
                headers: corsHeaders,
                body: JSON.stringify({
                    error: 'Translation failed',
                    message: error.message
                })
            };
        }
    }

    // Handle unsupported methods
    console.log('Unsupported method:', event.httpMethod);
    return {
        statusCode: 405,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'Method not allowed' })
    };
};