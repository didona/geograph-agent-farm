
class CommandsController < ApplicationController
  protect_from_forgery

  respond_to :json, :html

  include ApplicationHelper
  include ActionView::Helpers::JavaScriptHelper

  #before_filter :authenticate_agent

  def execute
      return unless params[:agent]
      Madmass.current_agent = GeoAgent.first || GeoAgent.create
      status = Madmass.current_agent.run(params[:agent])
      @perception = Madmass.current_perception
      
    respond_to do |format|
      format.html {render :execute, :status => status}
      format.json {
        #render :json => @perception.to_json, :status => status
        render :json => "ciao".to_json, :status => status
      }
    end
 
 rescue Madmass::Errors::StateMismatchError
    # redirect_to :action => current_user.state
 
 end



end

