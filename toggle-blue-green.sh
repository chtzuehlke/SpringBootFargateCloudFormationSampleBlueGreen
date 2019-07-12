#!/bin/bash

PREFIX=${1:-default}

./update-stack-applicationloadbalancer.sh $PREFIX $(./get-inverted-blue-target.sh $PREFIX)

