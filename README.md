# Kafka docker image

A docker image for Kafka in [Kafka Raft metadata mode](https://github.com/apache/kafka/blob/trunk/config/kraft/README.md), no  Zookeeper required.

## Build

    docker build . -t kafka-kraft
    
## Run with Docker

    docker run -p 9092:9092 -d kafka-kraft
    
## Run with Docker compose

    docker compose up -d

## Docker on Mac

Endpoint to connect to Kafka from host is localhost:9092, for services inside docker containers it's kafka:9094. Make sure you use the same network.

## ECS

Set environment variable `KAFKA_ON_ECS` when running on ECS (not tested).
