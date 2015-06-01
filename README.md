

DEMO DevOps-Continuous Delivery on PaaS
----------------------------------------

The goal of this demo is to demonstrate how implementing continuous delivery practices using OpenShift Enterprise you can easly achieve:

- Moves forward artifacts in the delivery pipeline from Development, QA, UAT and Production environments
- Automates testing and provisioning processes
- Allows developers, QA and release teams to collaborate during the process reducing risks
- Automate create, deploy and destroy of complete environments (platform + application) on demand. Maximize usage of resources. 

![](https://raw.githubusercontent.com/amorena/democdonpaas/master/demo.png)

This demo uses docker-compose as a simple orchestration tool to start the Docker containers required for this demo. Docker is used for simplicity in this demo but is not essential to the delivery pipeline.

Openshift - PaaS value added to CD and DevOps
-------------------------------------------------

- standardize envs creation and configuration
- automate env provisioning and deployment
- easly create and destroy platform and applications combination (no need to schedule time for specific build or branches)
- minimize errors during build pipeline

DEMO environment
-------------------------------------------------

This demo uses the following components to create the delivery pipeline:

**"Ticket Monster" J2EE Application (JBoss EAP)**  

**3 Jenkins users / emails inbox: developer, tester and release**  

**Dovecot**  
Description: imap server  
Address: "127.0.0.1:25:25" "127.0.0.1:587:587" "127.0.0.1:143:143"  

**Rainloop**  
Description: Webmail   
Address:   
http://webmail:33100  
. user:jenkins@rhsummit.org / jenkins123  
. user:developer@rhsummit.org / developer123  
. user:tester@rhsummit.org / tester123  
. user:release@rhsummit.org / release123  
http://webmail:33100/?admin (ADMIN page)  
. user: admin / 12345  

**Jenkins**  
Description: continuous delivery orchestration engine  
Address: http://jenkins:8082/jenkins  

**Git (hosted on the jenkins container)**  
Description: source repository hosting the ticket-monster Java application  
Address: ssh://git@127.0.0.1:2200/tmpgit/ticketmonster.git  

**Sonatype Nexus**  
Description: artifact repository for archiving release binaries  
Address: http://nexus:8081/nexus  

**SonarQube**  
Description: static code analysis engine extracting various quality metrics from the code  
Address: http://sonar:9000  

**1 VM for Openshift environments (PROD env)**  
I've used the standard VM available from the customer portal  

Note: if running _boot2docker_ on Mac OSX, _DOCKER_HOST_ is the ip of boot2docker virtual machine. 

Delivery Pipeline
=================
The delivery pipeline in this demo is divided into five phases each containing a number of activities (jobs) that need to succeed in order to promote the artefact to the next phase. Each change in the application is a potential production release according to Continuous Delivery principles and can go in production if it successfully passes through all the phases in the pipeline.

1. BUILD: compilation and unit test, integration tests and static code analysis
2. DEV: release to Nexus, create release tag in Git, deploy to DEV server (on OpenShift online) and running functional tests
3. QA: deploy to System Test server (on OpenShift online) and running system tests
4. UAT: deploy to Performance Test server (on OpenShift online) and running performance tests
5. PROD: deploy to Production server (on OpenShift Enterprise)

![Delivery Pipeline](https://raw.githubusercontent.com/jbossdemocentral/continuous-delivery-demo/master/images/delivery-pipeline.png)

Instructions
============

1. Install [Docker Compose](https://docs.docker.com/compose/install/)
2. Clone this git repo

   ```
   git clone https://github.com/amorena/democdonpaas.git
   ```

3. Steps required ONLY if you wanna use OSE 2.x Virtual Machine (like I do at the moment)
	. DNS nameserver of the virtual machine needs to be configured in Jenkins (or local machine). Edit your local file `/etc/resolv.conf` 		  and add `nameserver 192.168.122.51` as the first nameserver (Optional: change attribute so that the file is immutable during the 		  demo)
	. Bound Docker containers network from "docker0" to "virbr0" (same network interface used by the VM). 
	  Edit /etc/sysconfig/docker-network.
	. Optional: Set docker containers IP range using "democdonpass/scripts/docker-setup-bridge.sh" (e.g: 192.168.122.2/24)

4. Local Host configuration for the Browser names resolution
	. Edit your local file `/etc/hosts` and add `127.0.0.1 jenkins nexus sonar rhsummit.org webmail` 
	
5. Start the containers
   ```
   cd democdonpaas
   docker-compose up -d
   ```
   This step will download the required Docker images from Docker registery and start all componenets: Jenkins, Nexus, Sonar, devoct and rainloop containers. Depending on your internet connection, it might take some minutes.

6. Browse to http://DOCKER_HOST:8082/jenkins and go to _Manage Jenkins > Configure System_. Scroll down to _OpenShift_ section and enter your OpenShift configs. If using OpenShift Online, enter your username and password in the respective textboxes. If using OpenShift Enterprise, also enter the address to your broker. Click on "Check Login" to validate your username and password. If successfull, click on "Upload SSH Public Key" to upload the Jenkins SSH keys to OpenShift.

  ![Jenkins Config](https://raw.githubusercontent.com/jbossdemocentral/continuous-delivery-demo/master/images/jenkins-config.png)

7. How to start the flow:
	1. Go to jobs list and start the _ticket-monster-build_ job.
	2. _git push_
	3. From JBoss developer studio - _Commit-Push_
8. Go to the _Delivery Pipeline_ tab to see how the build progresses in the delivery pipeline.

-------------------------------------------------------------------------------------------------------------------------------------------

Demo Stages (Jenkins jobs)
----------------------------

- Commit (owner developer): maven build + unit test + deploy/create to "dev" ose environment + email
- Acceptance (owner developer - automatically triggered by the Commit stage): deploy/create to "amqa" ose environment + Integration test ("hello" service) + email
- UAT (owner tester - manually trigger by the user): deploy/create to "uat" ose environment + integration test ("Home Page") + email
- Prod (owner release - manually trigger by the user): deploy/create to "prod" ose environment + email

Demo Flow
--------------------------

- Developer can check code in ("push" eg: from CLI or JDS) and this will trigger an automatic compilation and unit test (Commit)
- eg: Developer checks in code that breaks compilation and team gets notification build is broken
- Developer fix the issue and code that passes the Commit stage will automatically trigger a deployment to QA (Acceptance)
- Deployments to QA automatically trigger one or more functional acceptance or integration tests
- Code that passes the Acceptance stage will automatically notify the user tester
- Tester user can select any build that passes Acceptance and do a "push button" deployment to UAT (UAT stage)
- Release user can select any build in UAT and do a "push button" deployment to PROD (Production)

## Recognitions
I have improved my first version of this demo on the basis of a similar demo done afterwards by my collegue Siamak Sadeghianfar (who wrote the OpenShift Jenkins plugin). Furthermore thanks to Arun Gupta who has reviewed my initial work and provided useful inputs as well as Giuseppe Bonocore who has improved even further the Openshift Jenkins plugin.



