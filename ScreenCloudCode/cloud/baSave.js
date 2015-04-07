exports.beforeMovieSave = function(req, res) {
	if (!req.object.get('tmdbId')) {
		res.error("fail");
	} else {
		var query = new Parse.Query(Parse.Object.extend('Movie'));
		query.equalTo('tmdbId', req.object.get('tmdbId'));
		query.first({
			success: function(object) {
				if (object && object.id != req.object.id) {
					res.error(object.id);
				} else {
					res.success();
				}
			},
			error: function(error) {
				res.error('fail');
			}
		});
	}
}