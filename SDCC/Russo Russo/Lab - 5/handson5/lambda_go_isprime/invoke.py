import boto3
import json
import sys
import time
import base64

FUNCTION="IsPrime"

def invoke_function (n):
    payload={"N": n}

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
invoke_function(int(sys.argv[1] if len(sys.argv) > 1 else 4605137))
