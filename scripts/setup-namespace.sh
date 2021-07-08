#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

REPO="$1"
REPO_PATH="$2"
NAMESPACE="$3"
APPLICATION_BASE_PATH="$4"
APPLICATION_BRANCH="$5"

echo "Path: ${REPO_PATH}"

REPO_DIR=".tmprepo-dev-${NAMESPACE}"

SEMAPHORE="${REPO//\//-}.semaphore"
SEMAPHORE_ID="${SCRIPT_DIR//\//-}"

while true; do
  echo "Checking for semaphore"
  if [[ ! -f "${SEMAPHORE}" ]]; then
    echo -n "${SEMAPHORE_ID}" > "${SEMAPHORE}"

    if [[ $(cat "${SEMAPHORE}") == "${SEMAPHORE_ID}" ]]; then
      echo "Got the semaphore. Setting up gitops repo"
      break
    fi
  fi

  SLEEP_TIME=$((1 + $RANDOM % 10))
  echo "  Waiting $SLEEP_TIME seconds for semaphore"
  sleep $SLEEP_TIME
done

function finish {
  rm "${SEMAPHORE}"
}

trap finish EXIT

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

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

git add .
git commit -m "Adds dev config in '$NAMESPACE' namespace"
git push

cd ..
rm -rf "${REPO_DIR}"
