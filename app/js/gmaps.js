function initialize() {
  var myOptions = {
    center: new google.maps.LatLng(48.06292, 11.67243),
    zoom: 9,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  setMarkers(map, gon.locations);
}

function setMarkers(map, locations) {
  for (var i = 0; i < locations.length; i++) {
    var spot = locations[i];
    var when = spot[0];
    var pos = new google.maps.LatLng(spot[1], spot[2]);
    var marker = new google.maps.Marker({
      position: pos,
        map: map,
        title: when
    });
  }
}

function plot(map, locations) {
  var path = [];
  for(var i = 0; i < locations.length; i++) {
    path.push(new google.maps.LatLng(locations[i][1], locations[i][2]));
  }
  var movement = new google.maps.Polyline({
    path: path,
      strokeColor: "#FF0000",
      strokeOpacity: 1.0 ,
      strokeWeight: 0.5
  });
  movement.setMap(map)
}

google.maps.event.addDomListener(window, 'load', initialize);

