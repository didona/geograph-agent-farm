class DynamicProfilesController < ApplicationController
  respond_to :js, :html

  def new
      @dynamic_profile = DynamicProfile.new
  end

  def create
      @dynamic_profile = DynamicProfile.create(params[:dynamic_profile].merge({:user_id => current_user.id}))
      current_user.current_profile = @dynamic_profile
      current_user.save!
      render :layout => false
      #render 'farm/console'
  end


end
