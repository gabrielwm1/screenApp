define(['parse', 'navView', 'loginView'], function(Parse, NavView, LoginView) {

	var initialize = function() {

		Parse.initialize("sh5TWSiKn9Dmljgv0gJ5MiqrvTUxzE7BHP3kluUH", "ao3QIk1wU25Y8kXns2JGpgAKW8TMAKrif8OcQvwn");

		app = {

		};

		if (Parse.User.current()) {
			app.navView = new NavView();
		} else {
			app.loginView = new LoginView();
		}

	}

	return {
		initialize: initialize
	}

}); 