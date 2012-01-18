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