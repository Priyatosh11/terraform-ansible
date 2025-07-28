output "ec2_public_ip" {
    value = [
        for instance in aws_instance.my_instance : {
            public_ip = instance.public_ip
            name = instance.tags["Name"]
            }
    ]
}
