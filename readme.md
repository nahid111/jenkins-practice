##### <a href="https://www.youtube.com/watch?v=6YZvp2GwT0A">Youtube Link</a>
##### <a href="Reference: https://www.jenkins.io/doc/book/installing/docker/">Jenkins Docker installation</a>

## Installation

### Install Docker

```bash
sudo apt update
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

### Build the Image

```bash
docker build -t myjenkins-blueocean .
```

### Create the network 'jenkins'

```bash
docker network create jenkins
```

### Run the Container (MacOS / Linux)

```bash
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean
```

### Get the Password

```bash
docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword
```

### Connect to the Jenkins

```bash
https://localhost:8080/
```

### alpine/socat container to forward traffic from Jenkins to Docker engine on Host Machine

<a href="https://stackoverflow.com/questions/47709208/how-to-find-docker-host-uri-to-be-used-in-jenkins-docker-plugin">stackoverflow</a>

```bash
docker run -d --restart=always -p 127.0.0.1:2376:2375 --network jenkins -v /var/run/docker.sock:/var/run/docker.sock alpine/socat tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock
docker inspect <container_id> | grep IPAddress
```
