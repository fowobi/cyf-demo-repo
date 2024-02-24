provider "aws" {
  region = "us-east-1"
}

# EC2 Instance
resource "aws_instance" "backend_instance" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  key_name               = "videokeys"
  vpc_security_group_ids = ["sg-0bebb2642171d29a3"]
  
  tags = {
    Name = "terraform-server"
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "RDS endpoint: ${data.aws_db_instance.existing_database.endpoint}"
  EOF
}

# Use the existing RDS instance
data "aws_db_instance" "existing_database" {
  db_instance_identifier = "database-1"
}

# Create an S3 bucket
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "unique-fowobi-videos1"  # Replace with your actual bucket name
  acl    = "private"

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = jsonencode([
      {
        condition = {
          httpErrorCodeReturnedEquals = "404"
          keyPrefixEquals             = "error.html"
        }
        redirect = {
          protocol   = "https"
          replaceKey = "404.html"
        }
      },
    ])
  }
}
