#!/bin/bash

killall -9 java
java -Djava.net.preferIPv4Stack=true -Djgroups.bind_addr=127.0.0.1  -cp ${JBOSS_HOME}/modules/org/jgroups/main/jgroups-3.1.0.Alpha2.jar org.jgroups.stack.GossipRouter&
rm -rf ${JBOSS_HOME}/standalone/tmp/*
rm -rf ${JBOSS_HOME}/standalone/data/*
jruby -S bundle exec rake torquebox:run --trace
