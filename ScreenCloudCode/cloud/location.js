var _ = require('underscore');

exports.topMoviesForArea = function(req, res) {
	topMoviesForArea(req, res);
}

exports.topMoviesForAreaWebsite = function(req, res) {
	authenticateTheaterUser(req, function(isSuperUser) {
		if (isSuperUser) {
			topMoviesForArea(req, res);
		} else {
			res.error('Please Log In');
		}
	});
}

exports.authenticateTheaterUser = function(req, res) {
	authenticateTheaterUser(req, function(isTheaterUser) {
		if (isTheaterUser) {
			res.success('authenticated');
		} else {
			res.error('not authenticated');
		}
	});
}

function authenticateTheaterUser(req, callback) {
	if (!req.user) {
		callback(false);
	} else {
		var query = new Parse.Query(Parse.Role);
		query.equalTo('name', 'Theater');
		query.equalTo('users', req.user);
		query.first().then(function(adminRole) {
			if (adminRole) {
				callback(true);
			} else {
				callback(false);
			}
		});
	}
}

function topMoviesForArea(req, res) {
	//params:
		//latitude
		//longitude
		//radius
	console.log('radius: '+req.params.radius);

	var point = new Parse.GeoPoint({latitude: req.params.latitude, longitude: req.params.longitude});

	var locationQuery = new Parse.Query(Parse.Object.extend('MovieLocation'));
	locationQuery.withinKilometers('location', point, parseFloat(req.params.radius)/1000);
	if (req.params.limit) {
		locationQuery.limit(req.params.limit);
	} else {
		locationQuery.limit(1000);
	}
	locationQuery.include('movie');
	locationQuery.find({
		success: function(results) {
			var movieCounts = movieCountsForMovieLocations(results);
			res.success(movieCounts);
		},
		error: function(error) {
			res.error(error);
		}
	});
}

function movieCountsForMovieLocations(locations) {
	var movies = {};

	_.each(locations, function(location) {
		if (!movies[location.get('movieId')]) {
			movies[location.get('movieId')] = {count: 0, movie: location.get('movie'), location: location.get('location')};
		}
		movies[location.get('movieId')].count++;
	});

	var array = [];

	for (var key in movies) {
		array.push({movieId: key, count: movies[key].count, movie: movies[key].movie});
	}

	array.sort(function(a, b) {
		return b.count - a.count;
	});

	return array;
}

exports.makeSampleLocationData = function(req, res) {

	var MovieLocation = Parse.Object.extend('MovieLocation');

	var movieIds = ['rA8i77grUY', 'JnLkOAXvxG', '3XTteQCthS', 'LbHj5ugWvS', 'uslrKq4ZoO', 'fD6BA08iM3', 'WrJ5IJdwCs', 'roQsZQaUIc', 'p7ksFYRtYU'];
	var count = [4, 45, 53, 65, 87, 45, 6, 76, 21];

	var geoPoint = new Parse.GeoPoint({latitude: 42.27641579512508, longitude: -83.73510441407177});

	var all = [];

	for (var i = 0; i < movieIds.length; i++) {
		var num = count[i];
		for (var ii = 0; ii < num; ii++) {
			var obj = new MovieLocation();
			obj.set('movieId', movieIds[i]);
			obj.set('location', geoPoint);
			all.push(obj);
		}
	}

	Parse.Object.saveAll(all, {
		success: function() {
			res.success();
		},
		error: function() {
			res.error();
		}
	});
}