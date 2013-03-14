class BenchmarkSchedule < ActiveRecord::Base
  attr_accessible :user_id, :iterations, :static_profile_id, :static_profile_progress, :active, :current_iteration, :start_time
  has_many :dynamic_profiles, :order => "position"
  belongs_to :static_profile
  belongs_to :user

  def start
		update_attribute(:active, true)  	
  end

  def reset
  	update_attributes(:active => false, :current_iteration => 1, :static_profile_progress => 0, :static_profile_id => nil)
  end

  def last_iteration?
  	self.iterations == self.current_iteration
  end

  def progress_data
  	progress_data = {}
  	
  	progress_data = {:current_progress => self.static_profile_progress}
    progress_data[:dynamic_profiles] = {}
    progress_data[:static_profiles] = {}
    
    if self.static_profile
      current_dynamic_profile = self.static_profile.dynamic_profile
      dynamic_index = self.dynamic_profiles.index(current_dynamic_profile) || -1
      dynamic_current_iteration = current_dynamic_profile.current_iteration || 1
      dynamic_iterations = current_dynamic_profile.iterations || 1

      self.dynamic_profiles.each_with_index do |dynamic_profile, dindex|
      	# progress for previous iterations
	      previous_progresses = (dynamic_profile.current_iteration - 1) * (100 / dynamic_profile.iterations)
	      dynamic_profile_iteration = dynamic_profile.current_iteration || 1
        if(dynamic_index < dindex)
          progress_data[:dynamic_profiles][dynamic_profile.id] = {:progress => previous_progresses, :current_iteration => dynamic_profile_iteration}
          progress_data[:static_profiles].merge! static_profiles_progress(dynamic_profile, 0)
        elsif(dynamic_index == dindex)
          this_progress = static_profiles_progress(dynamic_profile, 0)
          progress_data[:static_profiles].merge! this_progress
          medium_progress = this_progress.values.inject(0){ |sum, data| sum + data[:progress]  } / this_progress.size
          profile_progress = medium_progress > 100 ? 100 : medium_progress
          
          # add iterations to progress calculation
          profile_progress = profile_progress / dynamic_iterations
          progress_data[:dynamic_profiles][dynamic_profile.id] = {:progress => previous_progresses + profile_progress, :current_iteration => dynamic_profile_iteration}
        else
          progress_data[:dynamic_profiles][dynamic_profile.id] = {:progress => 100, :current_iteration => dynamic_profile_iteration}
          progress_data[:static_profiles].merge! static_profiles_progress(dynamic_profile, 100)
        end
      end
    else
    	self.dynamic_profiles.each_with_index do |dynamic_profile, dindex|
    		progress_data[:dynamic_profiles][dynamic_profile.id] = {:progress => 0, :current_iteration => dynamic_profile.current_iteration || 1}
        progress_data[:static_profiles].merge! static_profiles_progress(dynamic_profile, 0)
    	end
    end
    
    dynamic_profiles_size = progress_data[:dynamic_profiles].size > 0 ? progress_data[:dynamic_profiles].size : 1
    progresses_sum = progress_data[:dynamic_profiles].values.inject(0){ |sum, data| sum + data[:progress] }
    this_iteration = self.current_iteration || 1
    total_iterations = self.iterations || 1
    completed_progress = (this_iteration - 1) * (100 / total_iterations ) 
    progress_data[:global_progress] = ((progresses_sum / dynamic_profiles_size) / total_iterations) + (completed_progress)
    progress_data[:current_iteration] = this_iteration
    progress_data[:start_time] = self.start_time ? (self.start_time + 1.hour).strftime("%Y/%m/%d %H:%M:%S") : ''
    progress_data[:active] = self.active
    # put other active schedules
    active_schedules = BenchmarkSchedule.where("active = :active AND id <> :id", {:active => true, :id => self.id})
    progress_data[:active_schedules] = active_schedules.map(&:id)
    progress_data
  end

  private

  def static_profiles_progress(dynamic_profile, dynamic_progress)
    progress = {}
    profiles = dynamic_profile.static_profiles
    index_of_current = profiles.index(self.static_profile)
    current_is_present = !index_of_current.nil?

    profiles.each_with_index do |profile, index|
      if current_is_present
        # the current profile is in this group
        if(self.static_profile == profile)
          # this is the profile running now
          this_progress = self.static_profile_progress > 100 ? 100 : self.static_profile_progress
          progress[profile.id] = {:progress => this_progress }
        elsif(index < index_of_current)
        	# the current profile is after this one (this is completed)
          progress[profile.id] = {:progress => 100}
        else
          # the current profile is before this one (this not already started)
          progress[profile.id] = {:progress => 0}
        end
      else
        # use the progress from dynamic profile
        progress[profile.id] = {:progress => dynamic_progress} 
      end
    end
    progress
  end
end
