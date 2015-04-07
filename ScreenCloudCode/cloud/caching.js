var tmdbApiKey = 'f1bdb4ea74c2a649771b073ccb1bc8fe';
var _ = require('underscore');

var callback;
var ids = [];
var currentPage;
var totalPages = 0;

exports.nowPlayingMovieIds = function(req, res) {
	var NowPlaying = Parse.Object.extend('NowPlaying');

	var query = new Parse.Query(NowPlaying);
	var previousDay = new Date();
	previousDay.setDate(previousDay.getDate() - 1);
	query.greaterThan('createdAt', previousDay);
	query.find().then(function (results) {
		console.log('results length: '+results.length);
		if (results.length == 0) {
			callback = function(error) {

				var nowPlaying = new NowPlaying();
				nowPlaying.set('ids', ids);
				if (error) {
					nowPlaying.set('error', true);
				}
				nowPlaying.save();

				res.success(ids);
			}

			fetchNowPlayingPage(1);
		} else {
			res.success(results[0].get('ids'));
		}
	}, function(error) {
		res.success('doesnt exist');
	});

	

}

function fetchNowPlayingPage(page) {
	currentPage = page;

	Parse.Cloud.httpRequest({
		method: 'GET',
		url: 'http://api.themoviedb.org/3/movie/now_playing?api_key='+tmdbApiKey+'&page='+page,
		success: function(response) {
			if (totalPages == 0) {
				totalPages = response.data.total_pages;
			}
			var newIds = _.pluck(response.data.results, 'id');
			ids = ids.concat(newIds);
			if (response.data.page != totalPages) {
				fetchNowPlayingPage(response.data.page + 1);
			} else {
				callback();
			}
		},
		error: function(error) {
			console.log('error getting page: '+currentPage);
			currentPage++;
			if (currentPage < totalPages+1) {
				fetchNowPlayingPage(currentPage);
			} else {
				callback(true);
			}
		}
	});
}