#!/usr/bin/env bash

export KAFKA_PORT=9092
KAFKA_CONFIG="${KAFKA_HOME}/config/kraft/server.properties"

sed -r -i "s@^#?log.dirs=.*@log.dirs=/kafka@g" ${KAFKA_CONFIG}

if [[ -z "$KAFKA_LISTENERS" ]]; then
  echo 'Using default listeners'
else
  echo "Using listeners: ${KAFKA_LISTENERS}"
  sed -r -i "s@^#?listeners=.*@listeners=$KAFKA_LISTENERS@g" ${KAFKA_CONFIG}
fi

if [[ -z "$KAFKA_ADVERTISED_LISTENERS" ]]; then
  echo 'Using default advertised listeners'
elif [[ -n "$KAFKA_ON_ECS" ]]; then
  INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
  echo "Using advertised listeners: PLAINTEXT://${INSTANCE_IP}:${KAFKA_PORT}"
  sed -r -i "s@^#?advertised.listeners=.*@PLAINTEXT://${INSTANCE_IP}:${KAFKA_PORT}@g" ${KAFKA_CONFIG}
else
  echo "Using advertised listeners: ${KAFKA_ADVERTISED_LISTENERS}"
  sed -r -i "s@^#?advertised.listeners=.*@advertised.listeners=$KAFKA_ADVERTISED_LISTENERS@g" ${KAFKA_CONFIG}
fi

if [[ -z "$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP" ]]; then
  echo 'Using default listener security protocol map'
else
  echo "Using listener security protocol map: ${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP}"
  sed -r -i "s@^#?listener.security.protocol.map=.*@listener.security.protocol.map=$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP@g" ${KAFKA_CONFIG}
fi

if [[ -z "$KAFKA_INTER_BROKER_LISTENER_NAME" ]]; then
  echo 'Using default inter broker listener name'
else
  echo "Using inter broker listener name: ${KAFKA_INTER_BROKER_LISTENER_NAME}"
  sed -r -i "s@^#?inter.broker.listener.name=.*@inter.broker.listener.name=$KAFKA_INTER_BROKER_LISTENER_NAME@g" ${KAFKA_CONFIG}
fi

${KAFKA_HOME}/bin/kafka-storage.sh info -c ${KAFKA_CONFIG}

uuid=$(${KAFKA_HOME}/bin/kafka-storage.sh random-uuid)
${KAFKA_HOME}/bin/kafka-storage.sh format -t $uuid -c ${KAFKA_CONFIG}

/usr/bin/create-topics.sh &

${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_CONFIG}
