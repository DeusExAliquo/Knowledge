# Kafka / Vagrant / Zookeeper

## Introduction
A simple project to deploy a Kafka infrastructure using VirtualBox with 3 brokers and a manager.

## Resources
All the files come from [THIS GITLAB](https://gitlab.com/xavki/tutoriels-kafka/-/tree/main/05-vagrantfile?ref_type=heads), and you can find a French YouTube video about it [HERE](https://www.youtube.com/watch?v=V1VEixUusAM).

## Modifications
I edited the files slightly to match the new versions of Kafka.

## Usage Instructions
### Prerequisites
1. Download and install VirtualBox.
2. Download all the project files.

### Deploy the Infrastructure
Run the following command in the project folder:

```bash
vagrant up
```

To speed up the process, you can install these plugins beforehand:

```bash
vagrant plugin install vagrant-faster
vagrant plugin install vagrant-cachier
```

This will automatically create the entire Kafka infrastructure.

### Accessing the Infrastructure
Once setup is complete:
- Access the manager running locally at [http://192.168.12.77:9000](http://192.168.12.77:9000) via your web browser.
- Connect to any node using the following command:

```bash
vagrant ssh <node_name>
```

Node names:
- `kafka1`
- `kafka2`
- `kafka3`
- `kmanager`

### Managing Kafka
You can manage Kafka either through the manager or directly on the nodes.

#### From the Node
Once connected to a Kafka node, navigate to the Kafka folder with:

```bash
cd /opt/kafka/bin/
```

Alternatively, use the full path `/opt/kafka/bin/kafka-topics.sh` for all commands.

#### Common Commands
Check all topics:

```bash
./kafka-topics.sh --list --bootstrap-server localhost:9092
```

> Even if you specify a single broker, Kafka queries the entire cluster for the list of topics.
> You should have a default __consumer_offsets created and used by Kaafka.

Create a new topic:

```bash
./kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 3 --partitions 5 --topic topicTest3replications5partitions
```

Verify the topic creation by listing all topics again:

```bash
./kafka-topics.sh --list --bootstrap-server localhost:9092
```

#### From Anywhere on the Node
You can also use the full path for commands:

```bash
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

/opt/kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 3 --partitions 5 --topic topicTest3replications5partitions

/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

---
## Delete Vagrant VMs
You can delete all of your vagrants vms with a simple command:

```bash
vagrant destroy -f
```
## Thanks for reading!
I hope this helps you set up and manage your local Kafka infrastructure efficiently!