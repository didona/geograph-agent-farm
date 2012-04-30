# 
#  This file is part of geograph-agent-farm Expression project.description is undefined on line 5, column 57 in Templates/Licenses/license-lgpl-algo.txt..
# 
#  Copyright (c) 2010-2012  Algorithmica Srl
# 
#  geograph-agent-farm is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
# 
#  geograph-agent-farm is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
# 
#  You should have received a copy of the GNU Lesser General Public License
#  along with geograph-agent-farm. If not, see <http://www.gnu.org/licenses/>.
# 
#  Contact us via email at info@algorithmica.it or at
# 
#  Algorithmica Srl
#  Vicolo di Sant'Agata 16
#  00153 Rome, Italy
# 

class PerceptionsService

  def initialize(opts={})
    @topic_name = opts['topic']
    @host = opts['host']
    @port = opts['port']
    @topic = nil
  end

  def start
#    transport_config = org.hornetq.api.core.TransportConfiguration.new("org.hornetq.core.remoting.impl.netty.NettyConnectorFactory", connect_opts)
#    connection_factory = org.hornetq.api.jms.HornetQJMSClient.createConnectionFactoryWithoutHA( org.hornetq.api.jms::JMSFactoryType::CF, transport_config )
    @topic = TorqueBox::Messaging::Topic.new(@topic_name,  :host => @host,
                                            :port => @topic)
    Thread.new { run }
  end

  def stop
    @done = true
  end

  def run
    until @done
      begin
        perceptions = JSON(@topic.receive)
        puts "PERCEPTION: #{perceptions.inspect}"
        perceptions.each do |perception|
          Madmass::AgentFarm::Domain::UpdaterFactory.updater.update_domain(perception)
          #ActiveSupport::Notifications.instrument("geograph-generator.agent_queue_sent")
        end
      rescue Exception => ex
        Madmass.logger.debug ex
      end

    end
  end
end