class SettingsController < ApplicationController
  before_filter :create_settings
  respond_to :js, :html

  def map
    current_user.setting.map_url = params[:map_url]
    current_user.setting.save!
    render :layout => false
  end

  def stats
    setting = current_user.setting
    setting.stats_url = params[:stats_url]
    Rails.logger.debug("Saving stats url #{params[:stats_url]}")
    setting.save!
    setting.reload
    Rails.logger.debug("Saved stats url #{setting.stats_url}")
    render :layout => false
  end


  def create_settings
    current_user.setting = Setting.create() unless current_user.setting
    current_user.save!
  end
end
