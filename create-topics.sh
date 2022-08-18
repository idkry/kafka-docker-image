#!/usr/bin/env bash

[ -z $KAFKA_CREATE_TOPICS ] && exit 0

if [[ -z "$START_TIMEOUT" ]]; then
    START_TIMEOUT=600
fi

start_timeout_exceeded=false
count=0
step=10
while true
do
    timeout ${step} bash -c "</dev/tcp/localhost/${KAFKA_PORT}" 2>/dev/null
    [ $? -eq 0 ] && break
    echo "waiting for kafka to be ready"
    sleep $step;
    count=$((count + step))
    if [ $count -gt $START_TIMEOUT ]; then
        start_timeout_exceeded=true
        break
    fi
done

if $start_timeout_exceeded; then
    echo "Not able to auto-create topic (waited for $START_TIMEOUT sec)"
    exit 1
fi

IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
    echo "creating topics: $topicToCreate"
    IFS=':' read -a topicConfig <<< "$topicToCreate"
    if [ ${topicConfig[3]} ]; then
      $KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:${KAFKA_PORT} --replication-factor ${topicConfig[2]} --partitions ${topicConfig[1]} --topic "${topicConfig[0]}" --config cleanup.policy="${topicConfig[3]}"
    else
      $KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:${KAFKA_PORT} --replication-factor ${topicConfig[2]} --partitions ${topicConfig[1]} --topic "${topicConfig[0]}"
    fi
done
