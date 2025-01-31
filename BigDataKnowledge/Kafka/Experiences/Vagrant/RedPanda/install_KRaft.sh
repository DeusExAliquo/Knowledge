#!/usr/bin/bash

###############################################################
#  TITRE: 
#
#  AUTEUR:   Xavier
#  VERSION: 
#  CREATION:  
#  MODIFIE: 
#
#  DESCRIPTION: 
###############################################################

# Variables ###################################################

SCALA_VERSION="2.13"
KAFKA_VERSION="3.9.0"
VERSION=${SCALA_VERSION}-${KAFKA_VERSION}

echo "Kafka installation..."

# Java install ###################################################

echo "Java install"
apt install openjdk-11-jre-headless

# Bin install ###################################################

echo "Bin install"
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab
export SCALA_VERSION="2.13"
export KAFKA_VERSION="3.9.0"
export VERSION=${SCALA_VERSION}-${KAFKA_VERSION}
groupadd --system kafka
useradd -s /sbin/nologin --system -g kafka kafka
# wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${VERSION}.tgz
tar xzf kafka_${VERSION}.tgz
mv kafka_${VERSION} /opt/kafka
chown -R kafka:kafka /opt/kafka

# Create Kafka User ###################################################

echo "Create Kafka User"
mkdir -p /data/kafka
chown -R kafka:kafka /data/

# Truc ouais ###################################################

nodesnumber=$1
mynode=$2

generateLine=""

for i in $(seq 1 $nodesnumber); do
    if [ "$i" -eq "$mynode" ]; then
        generateLine="${generateLine}$i@localhost:9093,"
    else
        generateLine="${generateLine}$i@kafka$i:9093,"
    fi
done

generateLine=${generateLine%,}

generateListener="kafka${mynode}:9092"

cat <<EOF > /opt/kafka/config/kraft/server.properties
process.roles=broker,controller
node.id=${mynode}
controller.quorum.voters=${generateLine}
listeners=PLAINTEXT://:9092,CONTROLLER://:9093
inter.broker.listener.name=PLAINTEXT
advertised.listeners=PLAINTEXT://${generateListener}
controller.listener.names=CONTROLLER
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/data/kafka
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
EOF

echo "Configuration generated successfully in /opt/kafka/config/kraft/server.properties"


cat <<EOF > /etc/systemd/system/kafka.service
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=network.target
After=network.target

[Service]
Type=simple
User=kafka
Group=kafka

Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh /opt/kafka/config/kraft/server.properties
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Create UUID ###################################################

# /opt.kafka/bin/kafka-storage.sh format -t DvCC5GzASTCpbfNGoKcvtA -c config/kraft/server.properties
myuuid="G9YZ-apARyan-yvRdJ-Zvg"
/opt/kafka/bin/kafka-storage.sh format -t $myuuid -c /opt/kafka/config/kraft/server.properties

# Start systemmd

systemctl daemon-reload
systemctl start kafka
systemctl enable kafka