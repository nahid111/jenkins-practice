**<a href="https://www.jenkins.io/doc/book/installing/docker/">Jenkins docs</a>** | **<a href="https://www.youtube.com/watch?v=6YZvp2GwT0A">Youtube Link</a>**

## Installation

- **<a href="https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository">Install Docker</a>**

- Build the Image

  ```bash
  docker build -t myjenkins-blueocean .
  ```

- Create the network 'jenkins'

  ```bash
  docker network create jenkins
  ```

- Run the Container (MacOS / Linux)

  ```bash
  docker run --name jenkins-blueocean --restart=on-failure --detach \
    --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
    --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
    --publish 8080:8080 --publish 50000:50000 \
    --volume jenkins-data:/var/jenkins_home \
    --volume jenkins-docker-certs:/certs/client:ro \
    --volume /var/run/docker.sock:/var/run/docker.sock:rw \
    myjenkins-blueocean
  ```

- Get the Password

  ```bash
  docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword
  ```

- Connect to the Jenkins from browser

  ```bash
  https://localhost:8080/
  ```

## Dynamic docker agents

<a href="https://stackoverflow.com/questions/47709208/how-to-find-docker-host-uri-to-be-used-in-jenkins-docker-plugin">stackoverflow</a>

- Run alpine/socat container to forward traffic from Jenkins master to Docker engine on Host Machine

  ```bash
  docker run -d --restart=always -p 127.0.0.1:2376:2375 --network jenkins -v /var/run/docker.sock:/var/run/docker.sock alpine/socat tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock

  docker inspect <container_id> | grep IPAddress
  ```

## Trigger build on git push

- Create Pipeline in Jenkins
  - Under **Build trigger** mark the following
    - GitHub Hook TRIGGER FOR gitsCM POLLING
  - Select **Pipeline script from scm**
  - Set repo url and jenkins file location
- Setup a **Github webhook**
  - Go to repository > setting > webhook > Add Webhook
  - Set Payload URL as **ec2-host:8080/github-webhook/**
  - Set Content type as application/json
  - Mark just the push event
  - Mark active
  - save

## Send buid status back to gihub

- Add Github server in jenkins
  - Log into jenkins and install the **GitHub Integration** Plugin without restart
  - Go to Dashboard > Manage Jenkins > System > GitHub > Add Github Server
  - Add credentials
    - Insert the github **Access Token** as **Secret text** and give an id
  - Mark **Manage hooks**
- Add post build actions in your jenkins pipeline

  ```groovy
  post {
          always {
              // Report build status to GitHub using the GitHub Commit Status API
              script {
                  def commitSHA = sh(script: 'git rev-parse HEAD', returnStatus: true).toString().trim()
                  def context = 'Jenkins CI'  // Context for the status
                  def status = currentBuild.resultIsBetterOrEqualTo('SUCCESS') ? 'SUCCESS' : 'FAILURE'
                  def description = "${status} on Jenkins"

                  // Set the GitHub commit status
                  step([
                      $class: 'GitHubCommitStatusSetter',
                      context: context,
                      repoName: 'nahid111/jenkins-practice',
                      sha1: commitSHA,
                      status: status,
                      description: description,
                  ])
              }
          }
      }
  ```
