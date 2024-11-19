import json

def lambda_handler(event, context):
    return response(200, {"msg": "This is just a dummy code, soon the real code will be deployed :)"})

def response(status_code, body):
    """Helper function to generate HTTP response."""
    return {
        'statusCode': status_code,
        'body': json.dumps(body),
        'headers': {
            'Content-Type': 'application/json'
        }
    }
