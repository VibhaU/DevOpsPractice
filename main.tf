resource "tls_private_key" "terraform_key" {
  algorithm = "RSA"
}


resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform_key"
  public_key = tls_private_key.terraform_key.public_key_openssh
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example_instance" {
  ami           = "ami-0360c520857e3138f"  
  instance_type = "t3.micro"
  key_name      = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id] 


  connection {
    type        = "ssh"
    user        = "ubuntu"  
    private_key = tls_private_key.terraform_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
  inline = [
    "sudo apt update -y",
    "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
    "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt update -y",
    "sudo apt install -y docker-ce docker-ce-cli containerd.io",
    "sudo systemctl start docker",
    "sudo systemctl enable docker",
    "sudo docker pull pavan731/game", 
    "sudo docker run -d --name game -p 80:80 pavan731/game"
    ]
}
tags = {
    Name = "2048-instance"
  }
}



output "instance_ip" {
  value = aws_instance.example_instance.public_ip
}