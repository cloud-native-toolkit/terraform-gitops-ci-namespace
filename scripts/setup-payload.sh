#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

NAME="$1"
REPO="$2"
REPO_PATH="$3"
NAMESPACE="$4"
CONTENT_DIR="$5"

REPO_DIR=".tmprepo-payload-${NAMESPACE}-${NAME}"

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

mkdir -p "${REPO_PATH}"

cp -R "${CONTENT_DIR}/"* "${REPO_PATH}"

find "${REPO_PATH}" -name "*"

BRANCH=$(!git rev-parse --abbrev-ref HEAD)

git add .
git commit -m "Adds payload yaml for ${NAME}"
git pull origin "${BRANCH}" --rebase
git push origin "${BRANCH}:${BRANCH}"

cd ..
rm -rf "${REPO_DIR}"
