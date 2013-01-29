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

class FarmController < ApplicationController
  before_filter :authenticate_agent
  respond_to :js, :html
  #REMOVEME restore transact (instead of transact_def) HACK to test DEF
  around_filter :transact, :only => [:console]

  def index
    @agent = Madmass.current_agent
  end

  def console
    @agent_groups = CloudTm::AgentGroup.all
    @agent_groups.map(&:getAgents).flatten.each { |el| logger.debug el.inspect }
    @agent_group = CloudTm::AgentGroup.new
  end

  def choose_process
    Job.new.set(
      :name => params[:id],
      :distance => params[:distance]
    )
  end

  private

  #REMOVEME HACK to test DEF
  def transact_def
    #GET CACHE
    cache = get_ispn
    puts("\n################# got this cache #{cache.class}\n")

    #GET DistributedExecutorService (DES)
    #https://docs.jboss.org/author/display/ISPN/Infinispan+Distributed+Execution+Framework
    des = CloudTm::DefaultExecutorService.new(cache)
    puts("\n################# got this des #{des.class}\n")
    #EXECUTE transact on every node with DES
    results = des.submitEverywhere DEFTask.new do
      CloudTm::FenixFramework.getTransactionManager.withTransaction do
        yield
      end
    end
  end

  def transact
    CloudTm::FenixFramework.getTransactionManager.withTransaction do
      yield
    end
  end

  #REMOVEME HACK to test DEF
  def get_ispn
    ispnBackEnd = CloudTm::FenixFramework.getConfig.getBackEnd;
    ispnBackEnd.getInfinispanCache;
  end
end

#MOVEME HACK to test DEF
#FIXME BROKEN
#Cannot do: https://groups.google.com/forum/#!topic/jruby-users/krk9iND6ERg/discussion
=begin
class DEFTask
  java_implements java.util.Concurrent.Callable
  java_implements java.io.Serializable

  @@serialVersionUID = 3496135215525904755.0

  def initialize(&block)
    @work = block
  end

  def call
    @work.call
  end

end
=end
