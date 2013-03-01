class BenchmarkService

  def initialize(opts={})
    @sleep = opts['sleep']
  end

  def start
    Thread.new { run }
  end

  def stop
    @done = true
  end

  def run

    @current_benchmark = nil
    @step_start_time = nil
    #@current_position = 0
    @current_dynamic_profile = nil

    until @done

      Rails.logger.debug "== BENCHMARK SERVICE =="

      sleep(@sleep)

      benchmark = active_benchmark

      #there is no benchmark
      unless benchmark
        Rails.logger.debug "No active benchmark"
        sleep(@sleep)
        Rails.logger.debug "=================="
        next
      end

      # Stopping previous benchmark
      if @current_benchmark != benchmark
        @current_static_profile.stop if @current_static_profile
        Rails.logger.debug "Stopped profile"
      end

      #Switching to new benchmark
      if (@current_benchmark == nil || (@current_benchmark != benchmark))
        Rails.logger.debug "setting new benchmark"
        @current_benchmark = benchmark
        @step_start_time = Time.now
        #@current_position = 1

        @current_dynamic_profile = @current_benchmark.dynamic_profiles.first

        @current_static_profile = @current_dynamic_profile.static_profiles.first
        
        Rails.logger.debug "Starting profile at position"  #{@current_position}
        @current_static_profile.start
        Rails.logger.debug "=================="
        next
      end

      profile_progress = ((Time.now - @step_start_time) / (@current_static_profile.duration * 60)) * 100 
      @current_benchmark.update_attributes(:static_profile_id => @current_static_profile.id, :static_profile_progress => profile_progress)

      #Execution of current step
      #Checks if the step is finished
      if( (@current_static_profile.duration * 60) <= (Time.now - @step_start_time) )
        Rails.logger.debug "Step #{@current_static_profile.id} completed"
        @current_static_profile.stop
        sleep(2 * @sleep) #FIXME: put max among delays @current_static_profile.max_delay
        @step_start_time = Time.now
        
        #@current_position += 1
        #@current_static_profile = @current_benchmark.dynamic_profiles.first.static_profiles.where(:position => @current_position).first
        next_step

        #It was the last step
        unless @current_static_profile
          Rails.logger.debug "Benchmark completed"
          @current_benchmark = nil
          @step_start_time = nil
          #@current_position = 0
          next
        end
        #Start the new step
        Rails.logger.debug "New Step started"
        @current_static_profile.start
      end
      Rails.logger.debug "=================="
    end
  end

  private

  def next_step
    # Get the next profile
    previous_index = @current_dynamic_profile.static_profiles.index(@current_static_profile)
    if( @current_dynamic_profile.static_profiles.size == previous_index + 1 )
      # go to next dynamic profile
      previous_dynamic_index = @current_benchmark.dynamic_profiles.index(@current_dynamic_profile)
      if( @current_benchmark.dynamic_profiles.size == previous_dynamic_index + 1 )
        # benchmark completed!
        @current_static_profile = nil
        @current_dynamic_profile = nil
        @current_benchmark.update_attributes(:active => false, :static_profile_id => nil, :static_profile_progress => 0)
        @current_benchmark = nil
        Rails.logger.debug "=================="
        next
      else
        # go to next dynamic profile
        @current_dynamic_profile = @current_benchmark.dynamic_profiles[previous_dynamic_index + 1]  
        @current_static_profile = @current_dynamic_profile.static_profiles.first
      end
    else
      # go to next static profile
      @current_static_profile = @current_dynamic_profile.static_profiles[previous_index + 1]
    end
    @current_benchmark.update_attributes(:static_profile_progress => 0, :static_profile_id => @current_static_profile.id)
  end

  def active_benchmark
    benchmarks = BenchmarkSchedule.where(:active => true)
    if (benchmarks.count > 1)
      Rails.logger.error("Multiple benchmarks are active!")
      benchmarks.each do |b|
        Rails.logger.error("#{b.inspect}")
      end
    end

    benchmarks.first
  end

end

