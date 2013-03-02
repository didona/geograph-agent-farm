class BenchmarkSchedulesController < ApplicationController

  before_filter :get_schedule

  def update_iterations
    @schedule.iterations = params[:iterations]
    @schedule.save!
    render :layout => false
  end

  def set_benchmark
    profile = DynamicProfile.find(params[:profile])
    @schedule.dynamic_profiles << profile
    last_position = DynamicProfile.max_position(@schedule.id)
    profile.update_attribute(:position, last_position)
    render :layout => false
  end

  def play
    @schedule.active = true
    @schedule.save!
    render :layout => false
  end

  def stop
    @schedule.active = false
    @schedule.save!
    render :layout => false
  end

  def index
    unless current_user.benchmark_schedule
      current_user.benchmark_schedule = BenchmarkSchedule.create(:iterations => 1)
      current_user.save!
      get_schedule
    end
    @benchmarks = @schedule.dynamic_profiles || []
    @dynamic_profiles = current_user.dynamic_profiles
    @progress_data = get_progress_data
  end

  def remove_profile
    dynamic_profile = DynamicProfile.find(params[:profile])
    @schedule.dynamic_profiles.delete(dynamic_profile)
    render 'benchmarks', :layout => false
  end

  def sort
    params[:ids].each_with_index do |profile_id, index|
      dynamic_profile = DynamicProfile.find_by_id(profile_id)
      dynamic_profile.update_attribute(:position, index + 1) if dynamic_profile
    end
    render :nothing => true
  end

  def progress
    render :json => get_progress_data.to_json
  end

  private

  def get_schedule
   @schedule = current_user.benchmark_schedule
  end

  def get_progress_data
    progress_data = {:current_progress => @schedule.static_profile_progress}
    progress_data[:dynamic_profiles] = {}
    progress_data[:static_profiles] = {}
    current_static_profile = @schedule.static_profile
    if current_static_profile
      current_dynamic_profile = current_static_profile.dynamic_profile
      dynamic_index = @schedule.dynamic_profiles.index(current_dynamic_profile) || -1
      @schedule.dynamic_profiles.each_with_index do |dynamic_profile, dindex|
        if(dynamic_index < dindex)
          progress_data[:dynamic_profiles][dynamic_profile.id] = 0
          progress_data[:static_profiles].merge! static_profiles_progress(dynamic_profile.static_profiles, 0)
        elsif(dynamic_index == dindex)
          progress_data[:static_profiles].merge! static_profiles_progress(dynamic_profile.static_profiles, 0)
          medium_progress = progress_data[:static_profiles].values.inject(0){ |sum, prog| sum + prog } / progress_data[:static_profiles].size
          progress_data[:dynamic_profiles][dynamic_profile.id] = medium_progress > 100 ? 100 : medium_progress
        else
          progress_data[:dynamic_profiles][dynamic_profile.id] = 100
          progress_data[:static_profiles].merge! static_profiles_progress(dynamic_profile.static_profiles, 100)
        end
      end
    end
    progress_data
  end

  def static_profiles_progress(profiles, dynamic_progress)
    progress = {}
    index_of_current = profiles.index(@schedule.static_profile)
    current_is_present = !index_of_current.nil?
    profiles.each_with_index do |profile, index|
      if current_is_present
        # the current profile is in this group
        if(@schedule.static_profile == profile)
          # this is the profile running now
          progress[profile.id] = @schedule.static_profile_progress
        elsif(index < index_of_current)
          # the current profile is after this one (this is completed)
          progress[profile.id] = 100
        else
          # the current profile is before this one (this not already started)
          progress[profile.id] = 0
        end
      else
        # use the progress from dynamic profile
        progress[profile.id] = dynamic_progress
      end
    end
    progress
  end

end
