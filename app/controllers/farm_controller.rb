class FarmController < ApplicationController
  before_filter :authenticate_agent
  respond_to :js, :html
  
  def index
    @agent = Madmass.current_agent
  end

  def console
    @agent_groups = AgentGroup.all
    @agent_group = AgentGroup.new
  end

  def choose_process
    Job.new.set(
      :name => params[:id],
      :distance => params[:distance]
    )
  end
end
