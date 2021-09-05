how to organise the tf files \
https://smartlogic.io/blog/how-i-organize-terraform-modules-off-the-beaten-path/










#### aws command line 
listing ec2 instnce only in tobular form
aws ec2 describe-instances ^
    --filters Name=tag-key,Values=Name ^
    --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name']|[0].Value}" ^
    --output table
    
    Source: https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
    

#### Best tf resources
https://www.koding.com/docs/terraform/providers/aws/r/instance.html/https://www.koding.com/docs/terraform/providers/aws/r/instance.html/

#### A blog on how to use tf as a pro

https://iamondemand.com/blog/how-to-use-terraform-like-a-pro-part-2/
