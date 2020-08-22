# Data stream analyitcs proof of concept using Kafka Streams

## Stream

A stream is main concept of Kafka Streams. It is an ordered, replayable, and fault-tolerant sequence of immutable data records. Data record is defined as a key-value pair. It can be considered as either a record stream (defined as KStream) or a changelog stream (defined as KTable). This dataset is an unbounded and being updated continuously. 

## Stream Processor
It represents a processing step in a topology. It is basically our processing logic that we want to apply on streaming data. The aim is to enable processing of data that is consumed from Kafka and will be written back into Kafka. Two options available for processing stream data:

* High-level Kafka Streams DSL.
* A lower-level processor that provides APIs for data-processing, composable processing, and local state storage.

### High-Level DSL
It is composed of two main abstractions: KStream and KTable or GlobalKTable.

1. KStream

    A KStream is an abstraction of record stream where each data is a simple key value pair in the unbounded dataset. It provides joining methods for joining multiple streams and aggregation methods on stream data. It provides many functional ways to manipulate stream data like

    * map 
    * mapValue 
    * flatMap 
    * flatMapValues 
    * filter 


2. KTable

    A KTable is an abstraction of a changelog stream. In this change log, every data record is considered an Insert or Update (Upsert) depending upon the existence of the key as any existing row with the same key will be overwritten.

### Processor API
The low-level Processor API provides a client to access stream data and to perform business logic on the incoming data stream and send the result as the downstream data. It is done via extending the abstract class AbstractProcessor and overriding the process method which contains our logic. This process method is called once for every key-value pair. Where the high-level DSL provides ready to use methods with functional style, the low-level processor API provides you the flexibility to implement processing logic according to your need. The trade-off is just the lines of code you need to write for specific scenarios.

## How to Run the application

### Starting up Kafka and Creating Topic

Make sure that you have installed Confluent and Confluent CLI for spinning up Kafka environment easily on local development environment.
Make sure that you have Java 8+ JDK and Apache Maven Build Automation system already installed on your local development environment.
```
$ export JAVA_HOME=/Users/kemalatik/etc/jdk-11.0.8.jdk/Contents/Home
$ export PATH="${JAVA_HOME}/bin:$PATH"
$ export CONFLUENT_HOME=/Users/kemalatik/etc/confluent-5.3.2
$ export CONFLUENT_CLI=/Users/kemalatik/etc/confluent-cli
$ export PATH="${CONFLUENT_HOME}/bin:$PATH"
$ export PATH="${CONFLUENT_CLI}/bin:$PATH"
$ ./confluent local start kafka
Updates are available for confluent. To install them, please run:
$ confluent update

    The local commands are intended for a single-node development environment
    only, NOT for production usage. https://docs.confluent.io/current/cli/index.html

Using CONFLUENT_CURRENT: /var/folders/9d/8tj1tdgx4tvbq4rmr4xdtfkr0000gp/T/confluent.B25OyaXW
Starting zookeeper
zookeeper is [UP]
Starting kafka
kafka is [UP]
```
Create the input and output topics used by this example.
```
$ bin/kafka-topics --create --topic numbers-topic \
                    --zookeeper localhost:2181 --partitions 1 --replication-factor 1
$ bin/kafka-topics --create --topic sum-of-odd-numbers-topic \
                    --zookeeper localhost:2181 --partitions 1 --replication-factor 1
```

### Starting up java application

The application will try to read from the specified input topic, execute the processing logic, and then try to write back to the specified output topic. In order to observe the expected output stream, you will need to start a console producer to send messages into the input topic and start a console consumer to continuously read from the output topic. Application must have access to the Kafka/ZooKeeper clusters you configured in the code examples. By default, the code examples assume the Kafka cluster is accessible via localhost:9092 (aka Kafka's bootstrap.servers parameter) and the ZooKeeper ensemble via localhost:2181. 
```
export MAVEN_HOME =/Users/kemalatik/etc/apache-maven-3.5.0
export PATH="${MAVEN_HOME}/bin:$PATH"
```

Create a standalone jar

```
$ mvn clean package
```

Run an example application using the the standalone jar.
```
$ java -cp target/kafka-streams-examples-5.5.0-standalone.jar \
  -Dlog4j.configuration=file:src/main/resources/log4j.properties \
  io.confluent.examples.streams.WordCountLambdaExample
```

Write some input data to the source topic by running data producer `SumLambdaExampleDriver`. The running example application will automatically process this input data and write the results to the output topic.

```
$ java -cp target/kafka-streams-examples-5.5.0-standalone.jar io.confluent.examples.streams.SumLambdaExampleDriver
```

Inspect the results data in the output topic using `kafka-console-consumer`
```
$ bin/kafka-console-consumer --topic sum-of-odd-numbers-topic --from-beginning \
                              --bootstrap-server localhost:9092 \
                              --property value.deserializer=org.apache.kafka.common.serialization.IntegerDeserializer
```
