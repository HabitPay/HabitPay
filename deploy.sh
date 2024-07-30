#!/bin/bash

DOCKER_IMAGE=$1
APPLICATION_NAME=backend

IS_APPLICATION_RUNNING=$(sudo docker compose ls | grep $APPLICATION_NAME | grep running | sed 's/.*/true/')

if [ $IS_APPLICATION_RUNNING = "true" ]; then
    echo "Application is running. Starting the application..."

    local is_blue_running=$(sudo docker compose -p $APPLICATION ps | grep blue | grep Up | sed 's/.*/true/')
    if [ $is_blue_running = "true" ]; then
        echo "Blue is running. Turning on the green..."
        sudo docker compose -p $APPLICATION-green up -d

        # TODO: green healthcheck 추가

        echo "Green is running. Stopping the blue..."
        sudo docker compose -p $APPLICATION-blue down
    else
        echo "Green is running. Stopping the green..."
        sudo docker compose -p $APPLICATION-green down
    fi
    sudo docker compose up -d
else
    echo "Application is not running. Starting the application..."
    sudo docker compose up -d
fi
