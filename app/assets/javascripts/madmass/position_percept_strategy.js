$perceptStrategy("position" , function(percept){
  //$log("Strategy for percept 'position'. Percept => " + JSON.stringify(percept));
  $('.messages').append('<div> lat: ' + percept.data['latitude'] + ' - long: ' + percept.data['longitude'] + '</div>');
})

