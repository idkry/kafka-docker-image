FROM amazoncorretto:11

ENV KAFKA_VERSION=3.2.1
ENV SCALA_VERSION=2.13

ENV KAFKA_HOME /opt/kafka
ENV PATH ${PATH}:${KAFKA_HOME}/bin

RUN yum install -y tar gzip && \
    curl "https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" --output /opt/kafka.tgz && \
    tar xzf /opt/kafka.tgz -C /opt && \
    ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} && \
    rm -f /opt/kafka.tgz

VOLUME ["/kafka"]

ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD create-topics.sh /usr/bin/create-topics.sh

WORKDIR ${KAFKA_HOME}

CMD ["start-kafka.sh"]
