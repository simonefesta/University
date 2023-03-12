import boto3
import json
import sys
import time
import base64

FUNCTION="hello"

def invoke_function (args=None):
    payload={}
    if args != None:
        for i in range(len(args)):
            payload["key{}".format(i+1)]=args[i]


    # Synchronous invocation
    response = client.invoke(
        FunctionName=FUNCTION,
        InvocationType='RequestResponse',
        LogType='Tail',
        Payload=json.dumps(payload),
    )

    status_code = response['StatusCode']
    payload = response['Payload'].read().decode('utf-8')
    log_result = base64.b64decode(response['LogResult']).decode('utf-8')

    print("Status Code: {}".format(status_code))
    print("Payload:\n{}\n---".format(payload))
    print("Log:\n{}\n---".format(log_result))

client = boto3.client('lambda')
invoke_function(sys.argv[1:])
