angular.module('addus').factory('rulesResource',
	['$resource', ($resource) ->
		$resource 'api/rules/:id', {}, {
			list: { method: 'GET', isArray: true }
			get: { method: 'GET' }
			save: { method: 'PUT' }
			activate: { method: 'POST' }
			remove: { method: 'DELETE'}
		}
	])