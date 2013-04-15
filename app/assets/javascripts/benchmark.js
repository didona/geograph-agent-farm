var timerStatus = 'idle';

function refreshProgresses() {
  $.ajax({
    url: 'benchmark_schedules/progress',
    accept: 'json'
  }).done(function(data) {
    var globalProgress = $('#global-progress');
    var gprogress = data.active ? data.global_progress : 0
    globalProgress.html(gprogress + '%');
    globalProgress.css({width: gprogress + '%'});
    
    var currentDate = new Date();
    var startDate = new Date();
    if(data.start_time != '') {
      startDate = new Date(data.start_time);
    }  
    
    if( (startDate < currentDate) && data.active && (timerStatus == 'idle') && (data.global_progress > 0)) {
      $('#countup').countup({restart: true});  
      timerStatus = 'running';
    }
     
    if(data.global_progress >= 100 || !data.active) {
      $('#countup').countup({stop: true});
      timerStatus = 'idle'; 
      $('#message').html('Benchmark is idle');
    }

    var currentIteration = $('.current-iteration');
    currentIteration.html('#' + data.current_iteration);

    if(data.dynamic_profiles) {
      $.each(data.dynamic_profiles, function(key, value) {
        var realValue = data.active ? value.progress : 0;
        var progress = $('#dynamic-profile-progress-' + key);
        progress.html(realValue + '%');
        progress.css({width: realValue + '%'});
        $('#current-iteration-' + key).html('#' + value.current_iteration);
      });
    }
    if(data.static_profiles) {
      $.each(data.static_profiles, function(key, value) {
        var realValue = data.active ? value.progress : 0;
        var progress = $('#static-profile-progress-' + key);
        progress.html(realValue + '%');
        progress.css({width: realValue + '%'});
      });
    }
  });
}

function attachBenchmarkListeners() {
  setInterval(refreshProgresses, 10000);

  $('#dynamic-profiles-container').on('click', '.icon-trash', function(event) {
    event.stopPropagation();
    var icon = $(this);
    if(confirm("Are you sure you want remove profile " + icon.data('profile') + ' from this benchmark?')) {
      $.ajax({
        url: 'benchmark_schedules/remove_profile',
        data: { profile: icon.data('profile') },
        type: 'delete'
      }).done(function(data) {
          $('#dynamic-profiles-container').html(data);
        });
    }
  });

  $('#number_iterations').on('change', function() {
    $.ajax({
      url: 'benchmark_schedules/update_iterations',
      type: 'PUT',
      data: { iterations: $(this).val() }
    });
  });

  $('.profile-iterations').on('change', function() {
    var profile = $(this).data('profile');
    $.ajax({
      url: 'benchmark_schedules/update_profile_iterations',
      type: 'PUT',
      data: { profile: profile, iterations: $(this).val() }
    });
  });

  $('#add-dynamic-profile-button').on('click', function() {
    var dynamicProfile = $('#dynamic-profile-select').val();
    if(dynamicProfile == '') return;

    $.ajax({
      url: 'benchmark_schedules/set_benchmark',
      data: { profile: dynamicProfile },
      type: 'post'
    }).done(function(data) {
        $('#dynamic-profiles-container').html(data);
      });
  });


  // start the benchmark
  $('#start-benchmark-button').on('click', function() {
    $.ajax({
      url: 'benchmark_schedules/play',
      type: 'PUT',
      dataType: 'script',
      success: function() {
        $('#message').html('Benchmark is running');
      }
    });
  });

  // stop the benchmark
  $('#stop-benchmark-button').on('click', function() {
    $.ajax({
      url: 'benchmark_schedules/stop',
      type: 'PUT',
      success: function() {
        $('#message').html('Benchmark is stopped');
        $('#countup').countup({stop: true});
        timerStatus = 'idle';
      }
    });
  });
}