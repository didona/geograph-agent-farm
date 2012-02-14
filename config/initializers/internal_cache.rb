###############################################################################
###############################################################################
#
# This file is part of GeoGraph Agent Farm.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph Agent Farm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph Agent Farm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph Agent Farm.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Vicolo di Sant'Agata 16
# 00153 Rome, Italy
#
###############################################################################
###############################################################################

require 'torquebox-cache'
class InternalCache
  include Singleton
  CMD_SENT_KEY = 'cmd-sent' unless defined?(CMD_SENT_KEY)
  PERC_RCV_KEY = 'perc-rcv' unless defined?(PERC_RCV_KEY)

  AGENT_QUEUE_SENT_KEY = 'agent-queue-sent' unless defined?(AGENT_QUEUE_SENT_KEY)
  AGENT_QUEUE_RCV_KEY = 'agent-queue-rcv' unless defined?(AGENT_QUEUE_RCV_KEY)


  def initialize
    @cache = TorqueBox::Infinispan::Cache.new( :name => 'geograph-generator' )
#    clear
  end

  def clear
    @cache.put(CMD_SENT_KEY, 0)
    @cache.put(PERC_RCV_KEY, 0)
    @cache.put(AGENT_QUEUE_SENT_KEY, 0)
    @cache.put(AGENT_QUEUE_RCV_KEY, 0)
  end

  def agent_queue_sent
    @cache.increment(AGENT_QUEUE_SENT_KEY)
    puts "Geoggen Agent Queue sent: #{@cache.get(AGENT_QUEUE_SENT_KEY)}"
  end

  def agent_queue_rcv
    @cache.increment(AGENT_QUEUE_RCV_KEY)
    puts "Geoggen Agent Queue received: #{@cache.get(AGENT_QUEUE_RCV_KEY)}"
  end

  def cmd_sent
    @cache.increment(CMD_SENT_KEY)
    puts "Geoggen Commands sent: #{@cache.get(CMD_SENT_KEY)}"
  end

  def percept_received
    @cache.increment(PERC_RCV_KEY)
    puts "Geoggen Perceptions received: #{@cache.get(PERC_RCV_KEY)}"
  end

  def print
    puts ">>>>>>>>>>>> GEOGGEN STATS <<<<<<<<<<<<<<<"
    puts "Commands sent: #{@cache.get(CMD_SENT_KEY)}"
    puts "Perceptions received: #{@cache.get(PERC_RCV_KEY)}"
    puts "Agent Queue sent: #{@cache.get(AGENT_QUEUE_SENT_KEY)}"
    puts "Agent Queue received: #{@cache.get(AGENT_QUEUE_RCV_KEY)}"
    puts "<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>"
  end
  
end