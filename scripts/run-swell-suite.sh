#!/usr/bin/env bash

set -euxo pipefail

SUITE_NAME="$1"

if [[ -z "$SUITE_NAME" ]]; then
  echo "Variable SUITE_NAME is unset."
  exit 1
fi

# Set default value to `LOCAL_$(RANDOM) if unset`
: "${GITHUB_RUN_ID:=LOCAL_$RANDOM}"
export GITHUB_RUN_ID

# Set default value to current working directory
: "${GITHUB_WORKSPACE:=$PWD}"
export GITHUB_WORKSPACE

CI_WORKSPACE=/discover/nobackup/gmao_ci/swell/tier1/${GITHUB_RUN_ID}
CI_WORKSPACE_JOB=/discover/nobackup/gmao_ci/swell/tier1/${GITHUB_RUN_ID}/${SUITE_NAME}
EXPERIMENT_ID=swell-${SUITE_NAME}-${GITHUB_RUN_ID}

echo "----------------------------------------"
echo "CI_WORKSPACE=${CI_WORKSPACE}"
echo "CI_WORKSPACE_JOB=${CI_WORKSPACE}"
echo "EXPERIMENT_ID=${CI_WORKSPACE}"
echo "----------------------------------------"

mkdir -p $CI_WORKSPACE_JOB

source /discover/nobackup/gmao_ci/swell/tier1/${GITHUB_RUN_ID}/modules

# Get python version
PYVER=`python --version | awk '{print $2}' | awk -F. '{print $1"."$2}'`

export PATH=$CI_WORKSPACE/swell/bin:$PATH
export PYTHONPATH=${PYTHONPATH}:$CI_WORKSPACE/swell/lib/python$PYVER/site-packages

echo "PYTHONPATH=${PYTHONPATH}"

echo "experiment_id: $EXPERIMENT_ID" > $CI_WORKSPACE_JOB/${SUITE_NAME}-override.yaml
echo "experiment_root: $CI_WORKSPACE_JOB" >> $CI_WORKSPACE_JOB/${SUITE_NAME}-override.yaml

rm -r -f $HOME/cylc-run/${EXPERIMENT_ID}-suite

cd $CI_WORKSPACE_JOB
swell create ${SUITE_NAME} -m defaults -p nccs_discover -o $CI_WORKSPACE_JOB/${SUITE_NAME}-override.yaml
swell launch $CI_WORKSPACE_JOB/${EXPERIMENT_ID}/${EXPERIMENT_ID}-suite --no-detach --log_path $CI_WORKSPACE_JOB/${EXPERIMENT_ID}
