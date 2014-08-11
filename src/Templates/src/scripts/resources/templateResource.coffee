angular.module('app').factory('templateResource', ['$resource', ($resource) ->
		$resource 'api/template/:id', {}, {
			list:   { method: 'GET', isArray: true }
			get:	{ method: 'GET' }
			save: 	{ method: 'PUT' }
			remove: { method: 'DELETE'}
		}
	])