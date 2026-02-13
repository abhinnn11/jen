#!/bin/bash
set -e

# Detect docker socket group id from host
SOCK_GID=$(stat -c '%g' /var/run/docker.sock)

echo "Docker socket group id is: $SOCK_GID"

# Create docker group inside container if missing
if ! getent group docker >/dev/null; then
    groupadd -g $SOCK_GID docker
fi

# Add jenkins user to docker group
usermod -aG docker jenkins

# start Jenkins as jenkins user
exec su jenkins -c "/usr/bin/tini -- /usr/local/bin/jenkins.sh"
