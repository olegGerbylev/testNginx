#!/bin/bash
set -e

echo Build.SH: $1
ROOT=$(dirname $0)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
BUILD_DATE=$(date +"%Y-%m-%dT%T")
BUILD_COMMIT_ID=$(git rev-parse HEAD)


#export DOCKER_BUILDKIT=1
docker build . -f Dockerfile-for-build \
              --build-arg USER=$USER \
              --build-arg UID=$(id -u) \
              --build-arg GID=$(id -g) \
              --network=host \
              -t donor-front-build

docker run -v `pwd`:/app --network=host donor-front-build npm install
docker run -v `pwd`:/app --network=host donor-front-build npm run build

echo Create version file
cat > "$ROOT/build/version.json" <<EOF
{
    "component":"donor-front",
    "buildBranch":"$BRANCH",
    "buildDate":"$BUILD_DATE",
    "buildChangeSet":"$BUILD_COMMIT_ID"
}
EOF

echo Builing docker image ...
LABEL=`echo "$BRANCH" | tr '[:upper:]' '[:lower:]'`
echo $LABEL
docker build . -f Dockerfile -t donor-front:$LABEL
