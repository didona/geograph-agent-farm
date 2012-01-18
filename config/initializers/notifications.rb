ActiveSupport::Notifications.subscribe "madmass.command_sent"  do |name, start, finish, id, payload|
#  MessageCounter.instance.cmd_sent
end

ActiveSupport::Notifications.subscribe "geograph-generator.perception_received"  do |name, start, finish, id, payload|
#  MessageCounter.instance.percept_received
end

ActiveSupport::Notifications.subscribe "madmass.agent_queue_received"  do |name, start, finish, id, payload|
#  MessageCounter.instance.agent_queue_rcv
end

ActiveSupport::Notifications.subscribe "geograph-generator.agent_queue_sent"  do |name, start, finish, id, payload|
#  MessageCounter.instance.agent_queue_sent
end

