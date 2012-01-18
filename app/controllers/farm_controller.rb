class FarmController < ApplicationController
  before_filter :authenticate_agent

  def index
    @agent = Madmass.current_agent
  end

  def console
    @agent_groups = AgentGroup.all
    @agent_group = AgentGroup.new
  end
end
