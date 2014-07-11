angular.module('addus')
	.factory('userInfoResource', ['$resource', ($resource) ->
		$resource 'api/userinfo/', {}, {
			get:	{ method: 'GET' }
		}
	])