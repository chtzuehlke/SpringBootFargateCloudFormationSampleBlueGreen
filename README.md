# DevOps at AWS - let's play with AWS Fargate and CodePipeline

(this is based on https://github.com/chtzuehlke/SpringBootFargateCloudFormationSample)

## Overview

### Sample application (dev environment)

![Sample application](images/sample-app-dev.png)

Dev environment (managed by AWS CloudFormation):
- HTTP reverse proxy (AWS Application Load Balancer)
- A simple REST service (dockerized Spring Boot web application with flyway for automated DB migration)
- A simple relational DB schema (AWS RDS for MySQL)

### Sample application (test environment)

![Sample application](images/sample-app-test.png)

Test environment (managed by AWS CloudFormation):
- Blue service serves end user traffic
- Green service serves test traffic during blue/gren deployment

### Container registry and runtime

![Container registry and runtime](images/docker-registry-and-runtime.png)

Container management infrastructure (managed by AWS CloudFormation):
- Private docker registry (AWS ECR)
- Serverless container execution environment (AWS Fargate)

### CI/CD pipeline

![CI/CD pipeline](images/ci-cd-pipeline.png)

Infrastructure (managed by AWS CloudFormation):
- Private git repository (AWS CodeCommit)
- A simple CI/CD pipeline (AWS CodePipeline)
- Docker-based build jobs (AWS CodeBuild)

Pipeline (build, dev deployment, test blue/green deployment):
- Source stage: a `git push` (wired via CloudWatch events) triggers master branch checkout from CodeCommit repository
- Build stage: build Spring Boot runnable jar and docker image (maven, docker), push docker image v(n) to private docker registry, assemble CloudFormation Fargate (dev) stack-update properties
- DeployBlue stage: update Fargate (dev) environment: running task will be replaced by a new task based on docker image v(n)
- (Automated integration tests stage is not implemented yet)
- Stage2Build phase: assemble CloudFormation Fargate (test) stack- and CloudFormation Load Balancer (test) stack-update properties
- Stage2DeployGreen phase: update current Fargate (test) green service to docker image v(n). Current Fargate (test) blue service, based on docker image v(&lt;n), is still serving end user traffic
- Stage2Approval stage: manual approval after testing
- Stage2ToggleBlueGreen phase: update Load Balancer (test) stack to switch roles of the blue and the green service. End user traffic is now served by the newly promoted blue service, based on docker image v(n). The green service, based on docker image v(&lt;n), is still available for immediate rollback.

## Infrastructure-as-Code with CloudFormation

Pre-Conditions:
- AWS CLI installed & configured (sufficient IAM permissions, default region configured)
- Default VPC is present in the default AWS region
- Docker is installed and running
- Linux-like environment or macOS (bash, curl, sed, ...)
- openssl installed (used for password generation)
- General advice: read - and understand - all shell scripts and CloudFormation YAML templates before executing them
- Create a SSH key pair and associate the public key with your IAM user
- Git push to CodeCommit also requires configuration in ~/.ssh/config (see https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html)

Disclaimer:
- Not production ready yet (e.g. automation scripts w/o error handling)
- Flyway in prod might not always be feasible (ensure forward and backward compatibility of app and DB schema)

### Infrastructure setup - from zero to production in ~24'

	./setup-showcase.sh

### Deployment - from push to production in ~12'

Push new version trough the pipeline:

	git push aws

	#./curl-loop-blue.sh dev
	./curl-loop-green.sh test

In the AWS Web Console, go to CodePipeline and approve "blue/green toggling". Then:
	
	./curl-loop-blue.sh test

### Infrastructure teardown - from production to zero in ~29'

	./teardown-showcase.sh

## TODOs

- Get rid of green service in dev env (not required - wasted $$$)
- Resource taggig
- Least privilege IAM roles
- Error handling in scripts
- Automated integration tests (dev)
- Automated smoke tests (test)
- Switch to CDK
- CloudWatch alarms (e.g. SNS notification if application error log count > 0 for last n minutes period)
- Fix CloudWatch logging helpers (support blue/green)
- Improve deployment time
- Real/optimized blue/green deployment: desired count for green service can be 0 after pipeline is inactive for a while
- Edge cases: as soon as v(n+1) is arriving test (green), pending approval of v(n) must be auto-rejected (further look into this)
or transition to Stage2DeployGreen must be auto-disabled after entering Stage2DeployGreen and auto-enabled after approval/disapproval
