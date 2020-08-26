#!/bin/bash
NAME=TOPIC-DRIVER
#START_SCRIPT="nohup java -server -Dapplication=$NAME -XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -Xmx2g -Xms1g \
#            -cp ./classes:./lib/* com.voida.msdp.Main"

START_SCRIPT="nohup java -server -Dapplication=$NAME -XX:+UseG1GC -Dlog4j.configuration=file:src/main/resources/log4j.properties -XX:+HeapDumpOnOutOfMemoryError -Xmx2g -Xms1g \
            -cp ./target/streams-example-1.0.0.jar:./target/lib/* kafka.stateful.StateFullTransformDriver"


PID_FILE=topicdriver.pid
CONSOLE_LOG=./logs/stdout.log

# ***********************************************
# ***********************************************
# PID=`$DAEMON $ARGS >> $CONSOLE_LOG 2>&1 & echo $!`

ARGS="" # optional start script arguments
DAEMON=$START_SCRIPT

start() {
  PID=`$DAEMON $ARGS >> $CONSOLE_LOG 2>&1 & echo $!`
}

case "$1" in
start)
    if [ -f $PID_FILE ]; then
        PID=`cat $PID_FILE`
        if [ -z "`ps aux | grep -w ${PID} | grep -v grep`" ]; then
            start
        else
            echo "Already running [$PID]"
            exit 0
        fi
    else
        start
    fi

    if [ -z $PID ]; then
        echo "Failed starting"
        exit 3
    else
        echo $PID > $PID_FILE
        echo "Started [$PID]"
        exit 0
    fi
;;

status)
    if [ -f $PID_FILE ]; then
        PID=`cat $PID_FILE`
        if [ -z "`ps aux | grep -w ${PID} | grep -v grep`" ]; then
            echo "Not running (process dead but pidfile exists)"
            exit 1
        else
            echo "Running [$PID]"
            exit 0
        fi
    else
        echo "Not running"
        exit 3
    fi
;;

stop)
    if [ -f $PID_FILE ]; then
        PID=`cat $PID_FILE`
        if [ -z "`ps aux | grep -w ${PID} | grep -v grep`" ]; then
            echo "Not running (process dead but pidfile exists)"
            exit 1
        else
            PID=`cat $PID_FILE`
            kill -KILL $PID
            echo "Stopped [$PID]"
            rm  $PID_FILE
            exit 0
        fi
    else
        echo "Not running (pid not found)"
        exit 3
    fi
;;

restart)
    $0 stop
    sleep 5
    $0 start
;;

*)
    echo "Usage: $0 {status|start|stop|restart}"
    exit 1
esac
