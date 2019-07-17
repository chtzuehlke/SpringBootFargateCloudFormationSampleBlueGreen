#!/bin/bash

echo Start: $(date)

./teardown-stack-pipeline.sh dev
	
./teardown-stack-codecommit.sh dev
git remote rm aws

./teardown-n.sh test

./teardown.sh dev

echo End: $(date)
