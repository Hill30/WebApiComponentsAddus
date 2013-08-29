addus_module
	.factory('claimsService', ['$resource', ($resource) ->
		$resource 'api/claims/:claims', { claims:'@claims' }, {
				get: { method: 'GET' }
			}
])