#!/bin/bash
# User data for new EC2 instances
# Install httpd (Apache HTTP Server)
sudo su

# Update the package manager and install httpd
yum update -y
yum install -y httpd

# Start the httpd service and enable it to start on boot
systemctl start httpd
systemctl enable httpd

# A basic HTML file
echo "<h1>Hello World! This is the Frontend web app</h1>" > /var/www/html/index.html