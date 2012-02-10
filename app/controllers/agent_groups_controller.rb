class AgentGroupsController < ApplicationController
  include Madmass::Transaction::TxMonitor
  
  before_filter :authenticate_agent
  around_filter :transact
  
  respond_to :html, :js
  
  def index
    respond_with(@agent_groups = CloudTm::AgentGroup.all)
  end

  def create
    group_options = params[:agent_group].clone
    group_options[:delay] = group_options[:delay].to_i
    group_options[:status] = 'idle'
    agents = group_options.delete(:agents)
    @agent_group = CloudTm::AgentGroup.create_group(agents, group_options)
    @agent_groups = CloudTm::AgentGroup.all
    respond_with(@agent_group)
  end

  def update
    group_options = params[:agent_group].clone
    group_options[:delay] = group_options[:delay].to_i
    group_options[:agents_type] = "#{group_options[:agents_type].classify}Agent"
    agents = group_options.delete(:agents)
    @agent_group = CloudTm::AgentGroup.where(:id => params[:id].to_i).first
    @agent_group.modify(agents.to_i, group_options)
    @agent_groups = CloudTm::AgentGroup.all
    respond_with(@agent_group)
  end

  def destroy
    agent_group = CloudTm::AgentGroup.where(:id => params[:id].to_i).first
    agent_group.destroy
    @agent_groups = CloudTm::AgentGroup.all
  end

  def start
    agent_group = CloudTm::AgentGroup.where(:id => params[:id].to_i).first
    agent_group.start if agent_group
    @agent_groups = CloudTm::AgentGroup.all
  end

  def stop
    agent_group = CloudTm::AgentGroup.where(:id => params[:id].to_i).first
    agent_group.stop if agent_group
    @agent_groups = CloudTm::AgentGroup.all
  end

  def pause
    agent_group = CloudTm::AgentGroup.where(:id => params[:id].to_i).first
    agent_group.pause if agent_group
    @agent_groups = CloudTm::AgentGroup.all
  end

  private

  def transact
    tx_monitor do
      yield
    end
  end
end
