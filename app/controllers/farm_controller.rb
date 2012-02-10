class FarmController < ApplicationController
  before_filter :authenticate_agent
  respond_to :js, :html
  around_filter :transact, :only => [:console]
  
  def index
    @agent = Madmass.current_agent
  end

  def console
    @agent_groups = CloudTm::AgentGroup.all
    @agent_groups.map(&:getAgents).flatten.each{|el| logger.debug el.inspect}
    @agent_group = CloudTm::AgentGroup.new
  end

  def choose_process
    Job.new.set(
      :name => params[:id],
      :distance => params[:distance]
    )
  end

  private

  def transact
    CloudTm::TxSystem.getManager.withTransaction do
      yield
    end
  end
end
