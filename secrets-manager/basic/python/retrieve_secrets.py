import boto3
from botocore.exceptions import ClientError
import json  # Added to parse JSON secret

def get_secret():
    secret_name = "MySecretGenerated-lUs5nZ3e1kHr"
    region_name = "eu-west-3"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # Improved error handling
        print(f"Error retrieving secret: {e}")
        return None

    # Parse the secret string (assuming it's JSON)
    secret_string = get_secret_value_response['SecretString']
    
    try:
        secret = json.loads(secret_string)  # Convert JSON string to dict
        print(f"Password: {secret.get('password')}")  # Using .get() for safety
        print(f"Username: {secret.get('username')}")
        return secret
    except json.JSONDecodeError:
        print("Secret is not in JSON format. Raw secret:")
        print(secret_string)
        return secret_string

if __name__ == "__main__":
    get_secret()