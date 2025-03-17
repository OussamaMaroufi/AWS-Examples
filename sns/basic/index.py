import json

def handler(event, context):
    message_str = event['Records'][0]['Sns']['Message']
    m = json.loads(message_str)
    message = 'Hello {} {}!'.format(m['first_name'], m['last_name'])
    print(message)
    return