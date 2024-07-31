#!/bin/bash

DOCKER_IMAGE=$1
APPLICATION=HabitPay

healthcheck() {
    local container=$1
    local max_retries=10
    local sleep_time=5
    local retries=0

    while [ $retries -lt $max_retries ]; do
        local is_container_running=$(docker container inspect $container --format='{{json .State.Status}}' | sed 's/"//g')
        if [ $is_container_running = "running" ]; then
            echo "$container is running."
            return 0
        else
            echo "$container is not running. Retrying..."
            sleep $sleep_time
            retries=$((retries+1))
        fi
    done

    return 1
}

switch() {
    local current=$1
    local target=$2

    echo "$current is running. Turning on $target container..."
    sudo docker compose -p $APPLICATION up $target -d
    local exit_status=$(healthcheck $target)

    if [ $exit_status -eq 0 ]; then
        echo "$target is running. Stopping $current container..."
        sudo docker compose -p $APPLICATION stop $current
        echo "$current container stopped."
        echo "Complete to switch container. ($current -> $target)"
    else
        echo "Failed to run $target. Exiting..."
        exit 1
    fi
}

main() {
    local is_application_running=$(sudo docker compose -p $APPLICATION ls | grep running | sed 's/.*/true/')

    if [ $is_application_running = "true" ]; then
        echo "Application is running. Check the blue container status..."
        local is_blue_running=$(docker container inspect blue --format='{{json .State.Status}}' | sed 's/"//g')
        if [ $is_blue_running = "running" ]; then
            switch blue green
        else
            switch green blue
        fi
    else
        echo "Application is not running. Starting the application...(with blue container)"
        sudo docker compose -p $APPLICATION up postgres -d
        sudo docker compose -p $APPLICATION up pgadmin -d
        sudo docker compose -p $APPLICATION up blue -d
        sudo docker compose -p $APPLICATION up nginx -d
    fi
}

main