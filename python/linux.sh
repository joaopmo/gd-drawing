#!/bin/bash

BASEDIR=$(dirname "$0")

source "$BASEDIR"/cnn/bin/activate && python3 "$BASEDIR"/main.py "$@"
