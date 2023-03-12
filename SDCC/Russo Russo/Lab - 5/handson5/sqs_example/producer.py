import boto3
import sys

# Get the service resource
sqs = boto3.resource('sqs')

try:
    queue = sqs.create_queue(QueueName='handson')
except:
    # Get the queue. This returns an SQS.Queue instance
    queue = sqs.get_queue_by_name(QueueName='handson')

for line in sys.stdin:
    queue.send_message(MessageBody=line, MessageAttributes={
        'Author': {
            'StringValue': 'Gabriele',
            'DataType': 'String'
        }
    })

