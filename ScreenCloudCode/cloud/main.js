var bASave = require('cloud/baSave.js');
var caching = require('cloud/caching.js');
var rottentomatoes = require('cloud/rottentomatoes.js');
var location = require('cloud/location.js');
var _ = require('underscore');
var mandrill = require('mandrill');
mandrill.initialize('8mE57Dd29HBKx5WABuI0UQ');

var express = require('express');
var app = express();

app.set('views', 'cloud/templates');
app.set('view engine', 'ejs');
app.use(express.bodyParser());

app.get('/movie/:id', function(req, res) {
	Parse.Cloud.httpRequest({
		url: 'http://api.themoviedb.org/3/movie/'+req.params.id+'?api_key=f1bdb4ea74c2a649771b073ccb1bc8fe',
		success: function(response) {
			var obj = JSON.parse(response.text);
			res.render('movie', {movie: obj});
		},
		error: function(response) {
			res.send('error');
		}
	});
	// res.redirect('screen://movie?id='+req.params.id);
});

app.get('/share/:id', function(req, res) {
	// var request = JSON.parse(req);
	res.render('share', {id: req.params.id});
});

app.get('/', function(req, res) {
	res.render('index.ejs');
});

//Before & After baSave
Parse.Cloud.beforeSave('Movie', bASave.beforeMovieSave);

//Caching
Parse.Cloud.define('nowPlayingMovieIds', caching.nowPlayingMovieIds);

//RottenTomatoes
Parse.Cloud.define('rottenTomatoesForIds', rottentomatoes.rottenTomatoesForIds);

//Location
Parse.Cloud.define('topMoviesForArea', location.topMoviesForArea);
Parse.Cloud.define('topMoviesForAreaWebsite', location.topMoviesForAreaWebsite);
Parse.Cloud.define('authenticateTheaterUser', location.authenticateTheaterUser);
Parse.Cloud.define('makeSampleLocationData', location.makeSampleLocationData);

//USE THIS TO ADD A SUPER USER THAT CAN ACCESS ONLINE DATA
// Parse.Cloud.define('addTheaterUser', function(req, res) {
// 	//params:
// 		//uid: objectId of user

// 	var userQuery = new Parse.Query(Parse.User);
// 	userQuery.get(req.params.uid, {
// 		success: function(user) {
// 			var query = new Parse.Query(Parse.Role);
// 			query.get('GtfOb0cQAX', function(role) {
// 				role.relation('users').add(user);
// 				role.save();
// 				res.success('success');
// 			});
// 		},
// 		error: function(err) {
// 			res.error('error');
// 		}
// 	});
// });

Parse.Cloud.define('requestMovie', function(req, res) {

	//params:
		//title
		//description
		//user

	mandrill.sendEmail({
	    message: {
	      text: 'A Screen user has requested a movie with the title: "'+req.params.title+'".\n\nThe provided description is: "'+req.params.description+'". \n\nContact: ' + req.user.get('name') + ' - ' + req.user.get('username'),
	      subject: "Screen User Requested Movie",
	      from_email: "screen@screenapp.com",
	      from_name: "Screen App",
	      to: [
	        {
	          email: "tschear@gmail.com",
	          name: "Theo Schear"
	        }
	      ]
	    },
	    async: true
	  }, {
	    success: function(httpResponse) { res.success("Email sent!"); },
	    error: function(httpResponse) { res.error("Uh oh, something went wrong"); }
	  });

});

Parse.Cloud.define('friendRequestUser', function(req, res) {

	//params:
		//userId

	Parse.Cloud.useMasterKey();

	var User = Parse.Object.extend('_User');
	var user = new User({objectId: req.params.userId});
	user.relation('friendRequests').add(req.user);

	req.user.relation('sentFriendRequests').add(user);

	Parse.Object.saveAll([user, req.user], {
		success: function() {
			res.success();
		},
		error: function(error) {
			res.error(error)
		}
	});

});

Parse.Cloud.define('acceptFriendRequest', function(req, res) {

	//params:
		//userId

	Parse.Cloud.useMasterKey();

	var User = Parse.Object.extend('_User');
	var user = new User({objectId: req.params.userId});
	user.relation('sentFriendRequests').remove(req.user);
	user.relation('friendRequests').remove(req.user);
	user.relation('friends').add(req.user);

	req.user.relation('friendRequests').remove(user);
	req.user.relation('sentFriendRequests').remove(user);
	req.user.relation('friends').add(user);

	Parse.Object.saveAll([user, req.user], {
		success: function() {
			res.success();
		},
		error: function(error) {
			res.error(error);
		}
	});

});

app.listen();