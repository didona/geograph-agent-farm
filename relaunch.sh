#!/bin/bash

killall -9 java
java -cp /Users/vittorio/torquebox-current/jboss/modules/org/jgroups/main/jgroups-3.1.0.Alpha2.jar org.jgroups.stack.GossipRouter&
rm -rf ~/torquebox-current/jboss/standalone/tmp/*
rm -rf ~/torquebox-current/jboss/standalone/data/*
jruby -S bundle exec rake torquebox:run
