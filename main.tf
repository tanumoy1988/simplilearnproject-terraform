# # Creation of VM in AWS 
#  - Security group 

resource "aws_security_group" "allow_SSH" {
  name        = "allow_SSH"
  description = "Allow SSH inbound traffic"

  #  - INBOUND

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  #  - OUTBOUND RULES

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#  - key pair

resource "aws_key_pair" "deployer1" {
  key_name   = "deployer-key1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCefEjVw46k61FaCdeTAlohJ05OcUAN8DI9T82Euuy9BLzaYxT3YVjiWWQxOKdpaHWxMDgQa1JcS4+M9kzyqPKijhhfPxQTieKkjf4qJaklXNQ2IszIr1LYhX1assVvk9WTH491CsDrV6dnBSMVP0yJoUzBAJT9GeVYCrhtvtLS3TiXr4P9nUlXcpk7hFCVAex3dUU1yWppRBQSBmXHEzqFx0m3bw0g+uAkLhLOCuUo9ffrcDkIJ8+8Bfyznhd12fcESG3PjSedtE9W8G9GdypR0Ae5ICtOIMj3+A1a9EuagfWpKCjylNhtvSUL3sII9oUmdRIR4kDI7TvQHNtzY7kdG7g+TBg/zeFoiCd6WqUeT4ZFm7Wlu9rmnpyAGQpjQUqg39rGLrXkXaT5Yp5m1e1ukxLS5xgZEeGNU5LdNUdQv0S3dfwullUY8cQAnYHkz/8O58fD9nZKqm1F9jYly4hv2Rp+m4Fw4pNzwpabDjtiALdhRRrK+3qLL8ug03Wy+us= tanumoypikugmai@ip-172-31-23-21"
}

resource "aws_instance" "amzn-linux" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer1.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "Linux-Node"
    "ENV"  = "Dev"
  }

  depends_on = [aws_key_pair.deployer1]

}


####### Ubuntu VM #####


resource "aws_instance" "ubuntu" {
  ami                    = "ami-04505e74c0741db8d"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer1.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "UBUNTU-Node"
    "ENV"  = "Dev"
  }


  # Type of connection to be established
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./deployer")
    host        = self.public_ip
  }

  # Remotely execute commands to install Java, Python, Jenkins
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && upgrade",
      "sudo apt install -y python3.8",
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ >  /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-8-jre",
      "sudo apt-get install -y jenkins",
    ]
  }

  depends_on = [aws_key_pair.deployer1]

}