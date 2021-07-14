#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

REPO_PATH="$1"
APPLICATION_BASE_PATH="$2"
APPLICATION_BRANCH="$3"

mkdir -p "${REPO_PATH}"

HOST=$(echo "${REPO}" | sed -E "s~([^/]*)/.*~\1~g")
ORG=$(echo "${REPO}" | sed -E "~[^/]+/(.*)/.*~\1~g")
GIT_REPO=$(echo "${REPO}" | sed -E "~.*/(.*)~\1~g")

cat > "${REPO_PATH}/gitops-config.yaml" <<EOL
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitops-repo
data:
  parentdir: ${APPLICATION_BASE_PATH}
  protocol: https
  host: ${HOST}
  org: ${ORG}
  repo: ${GIT_REPO}
  branch: ${APPLICATION_BRANCH}
---
EOL
