#!/bin/bash

set -e  
set -x  

aws eks update-kubeconfig --region us-east-1 --name mgmt-comet-cluster
helm repo add jenkins https://charts.jenkins.io
helm repo add eks https://aws.github.io/eks-charts
helm repo update