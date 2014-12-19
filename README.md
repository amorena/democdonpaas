DEMO DevOps-Continuous Delivery on PaaS
----------------------------------------

the goal of this demo is to demonstrate how implementing continuous delivery practices with OpenShift Enterprise is easy to achieve:

    Deploy seamlessly from Development, QA, UAT and Production environments
    Automates testing and provisioning processes
    Allows developers, QA and release teams to collaborate reducing risks
    Create ose environments and deploy apps on demand

Openshift - PaaS value added to CD and DevOps
-------------------------------------------------

    standardize envs creation and configuration
    automate env provisioning and deployment
    easly create and destroy platform and applications combination (no need to schedule time for specific build or branches)
    minimize errors during build pipeline

DEMO environment
------------------

1 simple "Hello World" application (Tomcat cartridge)
3 Jenkins users: developer, tester and release - 1 email inbox for dev/tester/release
1 Enterprise source code (SCM) (GITLAB - GITHUB). This project is based on a local GIT Server.
1 Enterprise Artifact repository (Nexus). This project is based on a local MAVEN.
1 VM for Openshift environments. I've used the standard VM avalable from the customer portal.
1 Jenkins Server (external to Openshift)
4 Build pipeline Stages / OSE envs = Dev (Commit stage); QA (Acceptance stage); UAT (UAT stage); Prod (Prod stage)

Demo Stages (Jenkins jobs)
----------------------------

Commit (owner developer): maven build + unit test + deploy/create to "dev" ose environment + email

Acceptance (owner developer - automatically triggered by the Commit stage): deploy/create to "amqa" ose environment + Integration test ("hello" service) + email

UAT (owner tester - manually trigger by the user): deploy/create to "uat" ose environment + integration test ("Home Page") + email

Prod (owner release - manually trigger by the user): deploy/create to "prod" ose environment + email

Demo Flow
--------------------------

Developer can check code in ("push" eg: from CLI or JDS) and this will trigger an automatic compilation and unit test (Commit)

eg: Developer checks in code that breaks compilation and team gets notification build is broken

Developer fix the issue and code that passes the Commit stage will automatically trigger a deployment to QA (Acceptance)

Deployments to QA automatically trigger one or more functional acceptance or integration tests

Code that passes the Acceptance stage will automatically notify the user tester

Tester user can select any build that passes Acceptance and do a "push button" deployment to UAT (UAT stage)

Release user can select any build in UAT and do a "push button" deployment to PROD (Production)

DEMO Setup
-----------------

Install an external Jenkins Server and the following plugins: Build Pipeline, Openshift deployer, Authorize project, Email extension, Git, Matrix Authorization Strategy, Role-based Authorization

Configure Openshift server SSH Public Key Path in Jenkins configuration

Configure Jenkins Jobs (see xml config files in github repo)

Configure Jenkins emails accounts and setup (if required)

configure a Git Server hooks "post_update" so every "git push" will kick off a build pipeline in Jenkins ("Commit" job first)

Known issues
--------------------------

In the pipeline view, when I click on the console icon on one of the builds the dialog displays a "Server not found" error

Solution: remove "/" at line 150 of JENKINS_HOME/plugins/build-pipeline-plugin/build_pipeline.js
