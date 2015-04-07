define(['parse', 'backbone', 'text!loginTemplate'], function(Parse, Backbone, LoginTemplate) {

	var LoginView = Backbone.View.extend({
		el: 'body',

		template: _.template(LoginTemplate),

		events: {
			'submit #loginForm': 'loginClick'
		},

		initialize: function() {
			this.render();
		},

		render: function() {
			this.$el.html(this.template());
		},

		loginClick: function(ev) {
			ev.preventDefault();
			Parse.User.logIn($('#login').val(), $('#password').val(), {
				success: function(user) {
					Parse.Cloud.run('authenticateTheaterUser', {}, {
						success: function(user) {
							window.location = window.location;
						},
						error: function() {
							Parse.User.logOut();
							alert('Incorrect username or password');
						}
					});
				},
				error: function() {
					alert('Incorrect username or password');
				}
			});
		}
	});

	return LoginView;

});