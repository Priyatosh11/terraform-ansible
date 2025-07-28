#key pair login

resource "aws_key_pair" "my_key" {
  key_name= "terra-key-ansible"
  public_key = file("terra-key-ansible.pub")
  
}
#vpc(Virtual Private Cloud)  & Security group

resource aws_default_vpc default {
  
}

resource aws_security_group my_security_group {
  name = "automate-sg"
  description = "his will add a TF generated Security group"
  vpc_id = aws_default_vpc.default.id #interpolation(extract resources from a terraform block)

  #inbound rule
ingress{
    from_port = 22 #ssh port
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #source ip address
    description = "Allow SSH traffic from anywhere"
}
ingress{
    from_port = 80 #HTTP port
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #source ip address
    description = "Allow HTTP traffic from anywhere"
}

  #outbound rules
  egress{
    from_port = 0 #all traffic
    to_port = 0
    protocol = "-1" #all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic access"
  }
  tags = {
    name = "automate-sg"
  }
}

#ec2 instance
resource "aws_instance" "my_instance" {
  for_each = tomap({
    TWS-Junoon-Master = "ami-0d1b5a8c13042c939", #ubuntu
    TWS-Junoon-1 = "ami-0d1b5a8c13042c939", #ubuntu
    TWS-Junoon-2 = "ami-068d5d5ed1eeea07c", #Red Hat
    TWS-Junoon-3 = "ami-08ca1d1e465fbfe0c", #Amazon Linux 2
  })
  depends_on = [ aws_security_group.my_security_group, aws_key_pair.my_key ]
  ami = each.value
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_security_group.name]
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = each.key
  }
}

# resource "aws_instance" "my_new_instance" {
#   ami = "ami-04f167a56786e4b09"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "terra-sever1"
#   }
# }