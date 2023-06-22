# Base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y mysql-server grafana python3-pip supervisor

# Set up MySQL
RUN service mysql start && mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'tajnyheslo';" && mysql -e "CREATE DATABASE roobet;"

# Copy the SQL file
COPY db.sql /tmp/

# Import SQL file into MySQL
RUN service mysql start && mysql roobet < /tmp/db.sql

# Install Python dependencies
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt

# Copy the scraper script
COPY main.py /

# Copy the supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 3000

# Start supervisord
CMD service mysql start && supervisord -n
