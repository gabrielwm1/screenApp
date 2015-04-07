define(['backbone', 'parse', 'text!moviesTemplate', 'movieView'], function(Backbone, Parse, MoviesTemplate, MovieView) {

	var MoviesView = Backbone.View.extend({
		el: '#left',

		template: _.template(MoviesTemplate),

		initialize: function() {
			this.render();
		},

		render: function() {
			this.$el.html(this.template());
		},

		addAllMovies: function() {
			this.$('#moviesContainer').html('');
			_.each(this.movieCounts, function(movieCount) {
				if (movieCount.movie) {
					var movieView = new MovieView({movieCount: movieCount, maxDemand: this.movieCounts[0].count});
					$('#moviesContainer').append(movieView.el);
				}
			}, this);
		},

		updateForLatLngRadius: function(lat, lng, radius) {
			var that = this;
			Parse.Cloud.run('topMoviesForAreaWebsite', {latitude: lat, longitude: lng, radius: radius}, {
				success: function(results) {
					that.movieCounts = results;
					that.addAllMovies();
				},
				error: function(error) {
					console.log(error);
				}
			});
		}
	});

	return MoviesView;

});