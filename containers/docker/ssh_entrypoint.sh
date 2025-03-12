#!/bin/bash
set -e

echo "Running as user:"
echo "$USER"

echo "Starting SSH ..."
/usr/sbin/sshd

exec "$@"