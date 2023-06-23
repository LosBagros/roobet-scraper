# Base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y mysql-server python3-pip supervisor wget

# Set up MySQL
RUN mkdir -p /nonexistent && chown mysql:mysql /nonexistent
RUN service mysql start && \
    mysql -e "CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';" && \
    mysql -e "GRANT ALL PRIVILEGES ON roobet.* TO 'username'@'localhost';" && \
    mysql -e "CREATE DATABASE roobet;"

# Copy the SQL file
COPY db.sql /tmp/

# Import SQL file into MySQL
RUN service mysql start && mysql roobet < /tmp/db.sql

# Install Python dependencies
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt

# Install Grafana
RUN wget -O /tmp/grafana.deb https://dl.grafana.com/oss/release/grafana_10.0.1_arm64.deb && \
    dpkg -i /tmp/grafana.deb

# Copy the scraper script
COPY main.py /

# Copy the supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 3000

# Start supervisord
CMD mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    service mysql start && \
    supervisord -n
