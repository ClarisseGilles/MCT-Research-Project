#!/bin/bash
EXTRA_ARGS=""

if [[ ! -z "${PASSWORD}" ]]; then
  EXTRA_ARGS="--ServerApp.password='${PASSWORD}'"
fi

exec sudo -E -H -u "$(whoami)" PATH="${PATH}" XDG_CACHE_HOME="/home/$(whoami)/.cache" PYTHONPATH="${PYTHONPATH:-}" jupyter lab "${EXTRA_ARGS}"