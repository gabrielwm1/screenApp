define(['backbone', 'text!movieTemplate', 'parse'], function(Backbone, MovieTemplate, Parse) {

	var MovieView = Backbone.View.extend({
		tagName: 'div',

		template: _.template(MovieTemplate),

		initialize: function(options) {
			this.movieCount = options.movieCount;
			this.maxDemand = options.maxDemand;

			this.render();
		},

		render: function() {
			var title, imgUrl, count;
			if (this.movieCount.movie) {
				title = this.movieCount.movie.get('title');
				imgUrl = 'http://image.tmdb.org/t/p/w92/'+this.movieCount.movie.get('posterPath');
			}
			if (this.movieCount.count) count = this.movieCount.count;
			this.$el.html(this.template({title: title, imgUrl: imgUrl, userCount: count}));


			// console.log('width: '+demandBarWidth+', userCount: '+this.movieCount.count+', maxDemand '+this.maxDemand+', demandBarWidth '+$('#demandBar').width());
			this.$('.demandBar').css('clip', 'rect(0px, 0px, 3px, 0px)');

			var that = this;
			setTimeout(function() {
							var demandBarWidth = $('#demandBar').width() * (that.movieCount.count/that.maxDemand);	
							that.$(".demandBar").animate({
			  to: demandBarWidth //some unimportant CSS to animate so we get some values
			},
			{
				duration: 1000,
			  step: function(now, fx) { //now is the animated value from initial css value
			      $(this).css('clip', 'rect(0px, '+now+'px, 3px, 0px)')
			  }
			}, 10000);
			}, 100);
			

		}
	});

	return MovieView;

});