# Vars ###################################################

nodeNumbers=$1

# Docker install and run ###################################################
sudo apt install -y docker.io

sudo su root

generatedLine=""

for i in $(seq 1 $nodesnumber); do
    generatedLine="${generatedLine}kafka$i:9092,"
done

generatedLine=${generatedLine%,}

docker run  -d--network=host -p 8080:8080 -e KAFKA_BROKERS=$generatedLine docker.redpanda.com/redpandadata/console:latest