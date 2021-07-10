how to organise the tf files \
https://smartlogic.io/blog/how-i-organize-terraform-modules-off-the-beaten-path/










#### aws command line 
listing ec2 instnce only in tobular form
aws ec2 describe-instances ^
    --filters Name=tag-key,Values=Name ^
    --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name']|[0].Value}" ^
    --output table
    
    Source: https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
    
