define(['backbone', 'mapView', 'moviesView', 'text!navTemplate'], function(Backbone, MapView, MoviesView, NavTemplate) {

	var NavView = Backbone.View.extend({
		el: 'body',

		template: _.template(NavTemplate),

		initialize: function() {
			this.render();

			// if (navigator.geolocation) {
			// 	console.log('geo locaiton exists');
			// }
			// navigator.geolocation.getCurrentPosition(function(position) {
			// 	console.log('got position');
			// 	console.log(position);
			// });
		},

		render: function() {
			this.$el.html(this.template());

			this.mapView = new MapView();

			this.moviesView = new MoviesView();

			this.mapView.on('resize', function(params) {
				this.moviesView.updateForLatLngRadius(params.lat, params.lng, params.radius);
			}, this);
		}
	});

	return NavView;

});