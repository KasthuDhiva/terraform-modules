resource "aws_instance" "this" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y fontconfig openjdk-17-jre
    java -version
    sudo apt-get install -y docker.io docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
      https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    sudo docker volume create sonarqube_data
    sudo docker volume create sonarqube_logs
    sudo docker volume create sonarqube_db_data
    sudo bash -c 'cat <<EOF > /home/ubuntu/docker-compose.yml
    version: "3.8"
    services:
      sonarqube:
        image: sonarqube:latest
        container_name: sonarqube
        ports:
          - "9000:9000"
        volumes:
          - sonarqube_data:/opt/sonarqube/data
          - sonarqube_logs:/opt/sonarqube/logs
        environment:
          - SONARQUBE_JDBC_URL=jdbc:h2:tcp://db:9092/sonar
          - SONARQUBE_JDBC_USERNAME=sonar
          - SONARQUBE_JDBC_PASSWORD=sonar
        depends_on:
          - db
      db:
        image: postgres:latest
        container_name: sonarqube_db
        environment:
          - POSTGRES_USER=sonar
          - POSTGRES_PASSWORD=sonar
          - POSTGRES_DB=sonar
        volumes:
          - sonarqube_db_data:/var/lib/postgresql/data
    volumes:
      sonarqube_data:
      sonarqube_logs:
      sonarqube_db_data:
    EOF'
    sudo docker-compose -f /home/ubuntu/docker-compose.yml up -d
  EOF

  tags = {
    Name = var.name
  }
}
