provider "aws" {
  region = "ap-south-1"  # Mumbai region
}

module "jenkins_sg" {
  source      = "./modules/security_group"
  name        = "jenkins_sg"
  description = "Allow SSH, HTTP, and custom ports for Jenkins and SonarQube"
}

module "jenkins_server" {
  source             = "./modules/instance"
  ami                = "ami-0c2af51e265bd5e0e"  # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  instance_type      = "t3.medium"
  key_name           = "jenkins-windows"
  security_group_id  = module.jenkins_sg.security_group_id
  name               = "Jenkins-Server"
}

output "jenkins_server_public_ip" {
  value = module.jenkins_server.instance_public_ip
}
