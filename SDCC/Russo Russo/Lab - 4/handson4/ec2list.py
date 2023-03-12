import boto3

ec2 = boto3.resource('ec2')

for instance in ec2.instances.all():
    id = instance.id
    state = instance.state
    type = instance.instance_type
    print(f"{id} ({type}): {state['Name']}")
