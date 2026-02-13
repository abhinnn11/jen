#!/bin/bash

# Jenkins Docker Controller
# safe for persistent /opt/jenkins

set -e

COMPOSE="docker compose"
CONTAINER="jenkins"
JENKINS_HOME="/opt/jenkins"
BACKUP_DIR="/opt/jenkins_backups"

start() {
    echo "Starting Jenkins..."
    $COMPOSE up -d
    echo "Jenkins started"
}

stop() {
    echo "Stopping Jenkins..."
    $COMPOSE down
    echo "Jenkins stopped"
}

restart() {
    echo "Restarting Jenkins..."
    $COMPOSE down
    $COMPOSE up -d
    echo "Jenkins restarted"
}

rebuild() {
    echo "Rebuilding Jenkins image (safe, data preserved)..."
    $COMPOSE down
    $COMPOSE build --no-cache
    $COMPOSE up -d
    echo "Rebuild complete"
}

logs() {
    docker logs -f $CONTAINER
}

status() {
    echo "Container status:"
    docker ps -a | grep $CONTAINER || echo "Jenkins container not found"

    echo
    echo "Jenkins URL:"
    IP=$(hostname -I | awk '{print $1}')
    echo "http://$IP:8080"
}

backup() {
    echo "Creating Jenkins backup..."
    mkdir -p $BACKUP_DIR
    FILE="$BACKUP_DIR/jenkins-$(date +%F-%H%M).tar.gz"

    # important: quiet Jenkins during backup
    echo "Stopping Jenkins for consistent backup..."
    $COMPOSE down

    tar -czpf "$FILE" $JENKINS_HOME

    echo "Backup saved to: $FILE"

    echo "Starting Jenkins again..."
    $COMPOSE up -d
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    rebuild)
        rebuild
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    backup)
        backup
        ;;
    *)
        echo "Usage:"
        echo "./restart.sh start"
        echo "./restart.sh stop"
        echo "./restart.sh restart"
        echo "./restart.sh rebuild   (rebuild image safely)"
        echo "./restart.sh logs"
        echo "./restart.sh status"
        echo "./restart.sh backup    (safe Jenkins backup)"
        exit 1
        ;;
esac
