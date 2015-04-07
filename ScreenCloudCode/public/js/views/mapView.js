define(['backbone', 'async!https://maps.googleapis.com/maps/api/js?key=AIzaSyA2uEVqUU9YKdqF0wmovpnLgpT131SXqEU', 'text!mapViewTemplate'], 
	function(Backbone, Maps, MapViewTemplate) {

	var MapView = Backbone.View.extend({
		el: '#right',

		template: _.template(MapViewTemplate),

		radius: 10000,

		currentLat: 0,
		currentLng: 0,

		initialize: function() {
			this.render();
		},

		render: function() {
			this.$el.html(this.template());

			var mapOptions = {
	          center: { lat: 42.585444, lng: -84.726563},
	          zoom: 8
	        };
	        var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

	        var loc = google.loader.ClientLocation;
	        if (loc && loc.latitude && loc.longitude) {
	        	var location = new google.maps.LatLng(loc.latitude, loc.longitude);
	        	map.setCenter(location);
	        }

	        var that = this;

	        this.oldMarker = null;
	        this.oldCircle = null;

	       	google.maps.event.addListener(map, 'click', function(event) {
	       		console.log('latLng: '+event.latLng);
	       		if (that.oldMarker) {
	       			that.oldMarker.setMap(null);
	       		}
	       		if (that.oldCircle) {
	       			that.oldCircle.setMap(null);
	       		}

	       		that.currentLat = event.latLng.lat();
	       		that.currentLng = event.latLng.lng();
	       		that.triggerReload();

	       		var marker = new google.maps.Marker({
				    position: event.latLng,
				    map: map,
				    title:"Hello World!"
				});

				that.oldMarker = marker;

				marker.setMap(map);

				var populationOptions = {
			      strokeColor: '#FF0000',
			      strokeOpacity: 0.8,
			      strokeWeight: 2,
			      fillColor: '#FF0000',
			      fillOpacity: 0.35,
			      map: map,
			      center: {lat: event.latLng.lat(), lng: event.latLng.lng()},
			      radius: that.radius,
			      editable: true,
			      clickable: false
			    };
			    // Add the circle for this city to the map.
			    that.oldCircle = new google.maps.Circle(populationOptions);

			    google.maps.event.addListener(that.oldCircle, 'radius_changed', function() {
			    	console.log('radius: '+that.oldCircle.getRadius());
			    	that.radius = that.oldCircle.getRadius();
			    	that.triggerReload();
			    });
	       	});
		},

		triggerReload: function() {
			this.trigger('resize', {lat: this.currentLat, lng: this.currentLng, radius: this.radius});
		}
	});

	return MapView;

});