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

class MessageCounter
  include Singleton
  CMD_SENT_KEY = 'cmd-sent' unless defined?(CMD_SENT_KEY)
  PERC_RCV_KEY = 'perc-rcv' unless defined?(PERC_RCV_KEY)

  AGENT_QUEUE_SENT_KEY = 'agent-queue-sent' unless defined?(AGENT_QUEUE_SENT_KEY)
  AGENT_QUEUE_RCV_KEY = 'agent-queue-rcv' unless defined?(AGENT_QUEUE_RCV_KEY)


  def initialize
    
  end

  def clear
    cmd_sent = Message.where(:name => CMD_SENT_KEY).first
    cmd_sent.update_attribute(:count, 0) if cmd_sent
    
    perc_rcv = Message.where(:name => PERC_RCV_KEY).first
    perc_rcv.update_attribute(:count, 0) if perc_rcv
    
    queue_sent = Message.where(:name => AGENT_QUEUE_SENT_KEY).first
    queue_sent.update_attribute(:count, 0) if cmd_sent
    
    queue_rcv = Message.where(:name => AGENT_QUEUE_RCV_KEY).first
    queue_rcv.update_attribute(:count, 0) if queue_rcv
  end

  def agent_queue_sent
    msg = increment(AGENT_QUEUE_SENT_KEY)
    puts "Geoggen Agent Queue sent: #{msg.count}"
  end

  def agent_queue_rcv
    msg = increment(AGENT_QUEUE_RCV_KEY)
    puts "Geoggen Agent Queue received: #{msg.count}"
  end

  def cmd_sent
    msg = increment(CMD_SENT_KEY)
    puts "Geoggen Commands sent: #{msg.count}"
  end

  def percept_received
    msg = increment(PERC_RCV_KEY)
    puts "Geoggen Perceptions received: #{msg.count}"
  end

  def print
    puts ">>>>>>>>>>>> GEOGGEN STATS <<<<<<<<<<<<<<<"
    cmd_sent = Message.where(:name => CMD_SENT_KEY).first
    puts "Commands sent: #{cmd_sent ? cmd_sent.count : 0}"

    perc_rcv = Message.where(:name => PERC_RCV_KEY).first
    puts "Perceptions received: #{perc_rcv ? perc_rcv.count : 0}"

    agent_queue_sent = Message.where(:name => AGENT_QUEUE_SENT_KEY).first
    puts "Agent Queue sent: #{agent_queue_sent ? agent_queue_sent.count : 0}"

    agent_queue_rcv = Message.where(:name => AGENT_QUEUE_RCV_KEY).first
    puts "Agent Queue received: #{agent_queue_rcv ? agent_queue_rcv.count : 0}"
    puts "<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>"
  end

  private

  def increment(name)
    msg = Message.where(:name => name).first
    unless msg
      msg = Message.create(:name => name, :count => 0)
    end
    msg.count += 1
    msg.save
    msg
  end
  
end