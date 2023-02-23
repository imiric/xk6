#!/bin/sh
set -e

eval "$(fixuid)"

exec /go/bin/xk6 "$@"
