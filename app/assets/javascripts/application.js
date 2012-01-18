// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui-1.8.16.custom.min
//= require jtable
//= require jquery.blockUI

$(window).load(function() {
  $('#new-group-button').button();

  $('#new-group-button').ajaxStart(function(){
    $.blockUI({ css: {
      border: 'none',
      padding: '15px',
      backgroundColor: '#000',
      '-webkit-border-radius': '10px',
      '-moz-border-radius': '10px',
      opacity: .5,
      color: '#fff'
    } });
  });

  $('#new-group-button').ajaxStop(function(){
    $.unblockUI();
  });

  loadSliders();
});


function loadSliders() {
  $('.agents-slider').slider({
    min: 1,
    max: 100,
    step: 1,
    value: 1,
    create: function(event, ui) {
      var slider = $(this);
      var agents = slider.siblings('#agent_group_agents');
      $(this).slider('value', agents.attr('value'));
    },
    slide: function(event, ui) {
      var slider = $(ui.handle).parent();
      var group_id = slider.attr('rel');
      var label = $("#agents-selected-" + group_id);
      label.html(ui.value);

      var agents = slider.siblings('#agent_group_agents');
      agents.attr('value', ui.value);
    }
  });

  $('.delay-slider').slider({
    min: 1,
    max: 240,
    step: 1,
    value: 1,
    create: function(event, ui) {
      var slider = $(this);
      var delay = slider.siblings('#agent_group_delay');
      $(this).slider('value', delay.attr('value'));
    },
    slide: function(event, ui) {
      var slider = $(this);//$(ui.handle).parent();

      var group_id = slider.attr('rel');
      var label = $("#delay-selected-" + group_id);
      label.html(ui.value);

      var delay = slider.siblings('#agent_group_delay');
      delay.attr('value', ui.value);
    }
  });
}

function newGroup(){
  $('#new-group').dialog({
    title: "New Agent Group",
    height: 420,
    width: 450,
    buttons: {
      "create": function(){
        $( '#new_agent_group' ).submit();
        $( this ).dialog( "close" );
      }
    }
  });
}

function editGroup(group) {
  $('#edit-group-' + group['id']).dialog({
    title: "Edit Agent Group " + group['name'],
    height: 420,
    width: 450,
    buttons: {
      "update": function(){
        $( '#edit_agent_group_' + group['id'] ).submit();
        $( this ).dialog( "destroy" );
        $( this ).empty().remove();
      }
    }
  });
}

function destroyGroup(group) {
  $.ajax({
    url: 'agent_groups/' + group['id'],
    type: 'DELETE',
    dataType: 'script'
  });
}

function startGroup(group) {
  $.ajax({
    url: 'agent_groups/' + group['id'] + '/start',
    type: 'POST',
    dataType: 'script',
    headers: {
      'X-CSRF-Token': authenticity_token()
    }
  });
}

function stopGroup(group) {
  $.ajax({
    url: 'agent_groups/' + group['id'] + '/stop',
    type: 'POST',
    dataType: 'script',
    headers: {
      'X-CSRF-Token': authenticity_token()
    }
  });
}

function pauseGroup(group) {
  $.ajax({
    url: 'agent_groups/' + group['id'] + '/pause',
    type: 'POST',
    dataType: 'script',
    headers: {
      'X-CSRF-Token': authenticity_token()
    }
  });
}


function authenticity_token() {
  return $('meta[name="csrf-token"]').attr('content');
}

