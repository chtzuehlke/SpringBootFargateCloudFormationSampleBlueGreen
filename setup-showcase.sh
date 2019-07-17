#!/bin/bash

echo Start: $(date)

echo "Setup dev environment (private docker registry, loadbalancer, blue service, database):"
./setup.sh dev

echo "Setup test environment (loadbalancer, blue- and green services, database):"
./setup-n.sh test dev

echo "Setup private git repository:"
./create-stack-codecommit.sh dev
git remote add aws $(./get-stack-output.sh helloworld-dev-git CodeCommitRepositoryCloneURL)

echo "Setup CI/CD pipeline:"
./create-stack-pipeline.sh dev test

echo End: $(date)
