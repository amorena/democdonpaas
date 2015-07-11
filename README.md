

DEMO DevOps-Continuous Delivery on PaaS
----------------------------------------

The goal of this demo is to demonstrate how implementing continuous delivery practices using OpenShift - PaaS you can easly achieve:

- Moves forward artifacts in the delivery pipeline from Development, QA, UAT and Production environments
- Automates testing and provisioning processes
- Allows developers, QA and release teams to collaborate during the process reducing risks
- Automate create, deploy and destroy of complete environments (platform + application) on demand. Maximize usage of resources. 

![](https://raw.githubusercontent.com/amorena/democdonpaas/master/images/demo.png)

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

**Git Server (hosted on the jenkins container)**  
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
The delivery pipeline in this demo is divided into six phases each containing a number of activities (jobs) that need to succeed in order to promote the artefact to the next phase. Each change in the application is a potential production release according to Continuous Delivery principles and can go in production if it successfully passes through all the phases in the pipeline.

1. BUILD: automatic compilation and integration tests, release snapshot ver to Nexus and static code analysis. Send an email to Developer.
2. DEV:   automatic deploy to DEV server on PaaS (on OpenShift online) and runs tests, create release tag in GIT. Send an email to Developer.
3. DEV Teardown: automatic destroy of TicketmonsterVerSNAPSHOT env (app+platform)
5. QA TEST: automatic deploy of the same binary to QA server on PaaS (on OpenShift online) and runs tests. Send an email to Tester user.
4. UAT TEST: Tester user can do "push button" deploy (from Jenkins console - DeliveryPipeline tab) of the same binary to UAT server on PaaS (on OpenShift online). Automatic tests. Send an email to Release user.
6. PROD: Release user can do "push button" deploy (from Jenkins console - DeliveryPipeline tab) of the same binary to PROD server running on an on-premises PaaS (OpenShift Enterprise). Automatic tests.

![Delivery Pipeline](https://raw.githubusercontent.com/amorena/democdonpaas/master/images/delivery-pipeline.png)

VIDEO 
============
There is a recorded video available demonstrating the demo in action.[VIDEO](https://bluejeans.com/s/8p07/)

Instructions
============

1. Install [Docker Compose](https://docs.docker.com/compose/install/)
2. Clone this git repo

   ```
   git clone https://github.com/amorena/democdonpaas.git
   ```

3. This step is required ONLY if you wanna use "Openshift online" + Openshift enterprise 2.x Virtual Machine (current configuration)  
	. DNS nameserver of the virtual machine needs to be configured in Jenkins (or local machine)  
		. Edit your local file `/etc/resolv.conf`and add `nameserver 192.168.122.51` as the first nameserver (Optional: change attribute so that the file is immutable during the demo)    
	. Bound Docker containers network from "docker0" to "virbr0" (same network interface used by the VM).Edit /etc/sysconfig/docker-network.  
	. Optional: Set docker containers IP range using "democdonpass/scripts/docker-setup-bridge.sh" (e.g: 192.168.122.2/24)  

4. Local Host configuration for the Browser names resolution  
	. Edit your local file `/etc/hosts` and add `127.0.0.1 jenkins nexus sonar rhsummit.org webmail`   
	
5. Start the containers
   ```
   cd democdonpaas
   docker-compose up -d
   ```
   This step will download the required Docker images from Docker registery and start all containers: Jenkins, Nexus, Sonar, Dovecot and Rainloop.  
Depending on your internet connection, it might take some minutes.

6. Login (using jenkins user) to http://jenkins:8082/jenkins and go to _Manage Jenkins > Configure System_. Scroll down to _OpenShift_ section and enter your OpenShift configs. If using OpenShift Online, enter your username and password in the respective textboxes. If using OpenShift Enterprise, also enter the address to your broker. Click on "Check Login" to validate your username and password. If successfull, click on "Upload SSH Public Key" to upload the Jenkins SSH keys to OpenShift.  
NOTE: in this demo I've configured and rely on an hybrid configuration (Openshift online + local VM with OSE v2) 

  ![Jenkins Config](https://raw.githubusercontent.com/amorena/democdonpaas/master/images/jenkins-config.png)

7. You can start the flow in 3 ways:
	1. From the Jenkins console logged in as developer user go to jobs list and start the _ticket-monster-build_ job.
	2. _git push_ (remember to git pull first from the git server on jenkins docker container)
	3. From JBoss developer studio - _Commit-Push_ (remember to git pull first from the git server on jenkins docker container)

8. Login into Jenkins console using developer, tester and release users and Go to the _Delivery Pipeline_ tab to see how the build progresses in the delivery pipeline.

## Recognitions
I have improved my first version of this demo on the basis of a similar demo done afterwards by Siamak Sadeghianfar (who wrote the OpenShift Jenkins plugin). Furthermore thanks to Arun Gupta who has reviewed my initial work and provided some suggestions as well as Giuseppe Bonocore who has improved even further the Openshift Jenkins plugin.



