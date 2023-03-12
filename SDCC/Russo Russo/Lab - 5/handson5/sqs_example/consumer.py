import boto3

# Get the service resource
sqs = boto3.resource('sqs')

# Get the queue. This returns an SQS.Queue instance
queue = sqs.get_queue_by_name(QueueName='handson')

# Process messages by printing out body and optional author name
while True:
    for message in queue.receive_messages(MessageAttributeNames=['Author']):
        # Get the custom author message attribute if it was set
        author_text = ''
        if message.message_attributes is not None:
            author_name = message.message_attributes.get('Author').get('StringValue')
            if author_name:
                author_text = ' ({})'.format(author_name)

        # Print out the body and author (if set)
        print('{}: {}'.format(author_text, message.body))

        # Let the queue know that the message is processed
        message.delete()



