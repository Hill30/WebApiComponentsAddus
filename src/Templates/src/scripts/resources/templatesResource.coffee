angular.module('addus').factory('templatesResource', ['$resource', ($resource) ->
		$resource 'api/templates/:id', {}, {
			list:   { method: 'GET', isArray: true }
			save: 	{ method: 'PUT' }
			remove: { method: 'DELETE'}
		}
	])