class AgentGroupsController < ApplicationController
  before_filter :authenticate_agent
  
  respond_to :html, :js
  
  def index
    respond_with(@agent_groups = AgentGroup.all)
  end

  def create
    group_options = params[:agent_group].clone
    agents = group_options.delete(:agents)
    @agent_group = AgentGroup.create_group(agents, group_options)
    @agent_groups = AgentGroup.all
    respond_with(@agent_group)
  end

  def update
    group_options = params[:agent_group].clone
    agents = group_options.delete(:agents)
    @agent_group = AgentGroup.where(:id => params[:id]).first
    @agent_group.modify(agents.to_i, group_options)
    @agent_groups = AgentGroup.all
    respond_with(@agent_group)
  end

  def destroy
    agent_group = AgentGroup.where(:id => params[:id])
    agent_group.first.destroy
    @agent_groups = AgentGroup.all
  end

  def start
    agent_group = AgentGroup.where(:id => params[:id]).first
    agent_group.start if agent_group
    @agent_groups = AgentGroup.all
  end

  def stop
    agent_group = AgentGroup.where(:id => params[:id]).first
    agent_group.stop if agent_group
    @agent_groups = AgentGroup.all
  end

  def pause
    agent_group = AgentGroup.where(:id => params[:id]).first
    agent_group.pause if agent_group
    @agent_groups = AgentGroup.all
  end

end
