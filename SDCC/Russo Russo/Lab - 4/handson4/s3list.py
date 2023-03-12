import boto3

# Let's use Amazon S3
s3 = boto3.resource('s3')

print("Your buckets:")
# Print out bucket names and their content
for bucket in s3.buckets.all():
    print(f"> {bucket.name}")
    
    if "sdcc" in bucket.name or "dsp" in bucket.name:
        for obj in bucket.objects.all():
            print("  |--" + obj.key)
