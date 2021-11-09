#!/bin/bash

exec sudo -E -H -u "$(whoami)" PATH="${PATH}" XDG_CACHE_HOME="/home/$(whoami)/.cache" PYTHONPATH="${PYTHONPATH:-}" jupyter lab