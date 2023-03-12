import boto3

BUCKET="sdcc2223"

def my_handler(event, context):
    data=""
    for record in event['Records']:
        print("Got a message from SQS: {}".format(record['body']))
        payload=record["body"]
        data = data + "{}\n".format(payload)

    key = "sqsExample/{}".format(context.aws_request_id)
    s3 = boto3.resource('s3')
    object = s3.Object(BUCKET, key)
    object.put(Body=data.encode('utf-8'))

    return "OK"
