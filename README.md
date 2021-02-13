# aws_vpc
Creating a custom VPC on AWS using IaC.</br>
Using terraform to create infrastrucutre on AWS using code. In this code, we are trying to create a below items:

    VPC

    Subnet inside VPC

    Internet gateway associated with VPC

    Route Table inside VPC with a route that directs internet-bound traffic to the internet gateway

    Route table association with our subnet to make it a public subnet

    Security group inside VPC

    Key pair used for SSH access

    EC2 instance inside our public subnet with an associated security group and generated a key pair


