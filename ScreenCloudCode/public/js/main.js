require.config({
	paths: {
		//Libs
		'jquery': 'libs/jquery/jquery.min',
		'underscore': 'libs/underscore/underscore.min',
		'backbone': 'libs/backbone/backbone.min',
		'parse': 'libs/parse/parse.min',
		'bootstrap': 'libs/bootstrap/bootstrap',
		'async': 'libs/require/async',
		'animateClip': 'libs/animate.clip/jquery.animate.clip',

		//Views
		'mapView': 'views/mapView',
		'moviesView': 'views/moviesView',
		'navView': 'views/navView',
		'movieView': 'views/movieView',
		'loginView': 'views/loginView',
		
		//Templates
		'navTemplate': 'templates/navTemplate.html',
		'mapViewTemplate': 'templates/mapViewTemplate.html',
		'moviesTemplate': 'templates/moviesTemplate.html',
		'movieTemplate': 'templates/movieTemplate.html',
		'loginTemplate': 'templates/loginTemplate.html'
	},
	shim: {
		'backbone': {
            deps: ['underscore', 'jquery'],
            exports: 'Backbone'
        },
        'underscore': {
            exports: '_'
        },
        'parse':{
        	exports: 'Parse'
        },
        'bootstrap': {
        	deps: ['jquery'],
        	exports: 'Bootstrap'
        },
        'animateClip': {
        	deps: ['jquery'],
        	exports: 'jQuery.animate'
        }
	}
});

require(['app'], function(App) {
	App.initialize();
});