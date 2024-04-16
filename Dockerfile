
FROM phusion/baseimage:jammy-1.0.3
LABEL Name=handle_server Version=1.0.0

## Image config

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Update installed APT packages
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

RUN apt-get install -y git ntp wget openjdk-11-jdk python3 mysql-client libmariadb-java maven

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Handle Server setup

# Get the handle server package and put it in the container
ADD http://www.handle.net/hnr-source/handle-9.3.0-distribution.tar.gz /tmp/
RUN mkdir -p /opt/handle && tar xf /tmp/handle-9.3.0-distribution.tar.gz -C /opt/handle --strip-components=1

# Add the jdbc connector so it gets loaded
RUN ln -s /usr/share/java/mariadb-java-client.jar /opt/handle/lib/mariadb-java-client.jar

# Copy over the handle base configs and build script
COPY handle/ /home/handle/

RUN git clone https://github.com/DSpace/Remote-Handle-Resolver.git /tmp/dspace-plugin
WORKDIR /tmp/dspace-plugin
RUN mvn clean package
RUN cp /tmp/dspace-plugin/target/dspace-remote-handle-resolver-1.1-SNAPSHOT.jar /opt/handle/lib/

# Create the working directory for the handle server that will run in the container
RUN mkdir -p /var/handle/svr/logs

# Redirect log files to stdout/stderr
RUN ln -sf /dev/stdout /var/handle/svr/logs/access.log \
    && ln -sf /dev/stderr /var/handle/svr/logs/error.log

# Install Handle server as a service
RUN mkdir /etc/service/handle
COPY handle.sh /etc/service/handle/run
RUN chmod +x /etc/service/handle/run
