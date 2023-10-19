FROM jenkins/jenkins:2.414.3-jdk17
USER root
RUN apt-get update && apt-get install -y lsb-release

RUN apt-get install -y python3 python3-pip

# Download Go and install it to /usr/local/go
RUN curl -s https://storage.googleapis.com/golang/go1.21.3.linux-amd64.tar.gz | tar -v -C /usr/local -xz
ENV PATH $PATH:/usr/local/go/bin

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

USER jenkins
RUN jenkins-plugin-cli --plugins github-pullrequest:0.5.0
RUN jenkins-plugin-cli --plugins docker-plugin:1.5
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"