angular.module('addus').factory('userSettingsResource',
	['$resource', ($resource) ->
		$resource 'api/usersettings', {}, {
			get: { method: 'GET' }
			post: { method: 'POST' }
		}
	])