#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

NAMESPACE="gitops-dev-namespace"

if [[ ! -f "payload/1-infrastructure/namespace/${NAMESPACE}/gitops-config.yaml" ]]; then
  echo "Payload missing: payload/1-infrastructure/namespace/${NAMESPACE}/gitops-config.yaml"
  exit 1
fi

cat "payload/1-infrastructure/namespace/${NAMESPACE}/gitops-config.yaml"

if [[ ! -f "argocd/1-infrastructure/active/namespace-${NAMESPACE}.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/active/namespace-${NAMESPACE}.yaml"
  exit 1
fi

cat "argocd/1-infrastructure/active/namespace-${NAMESPACE}.yaml"

cd ..
rm -rf .testrepo
