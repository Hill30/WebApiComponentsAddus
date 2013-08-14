addus_module
  .factory('ClaimsService', ['$resource', ($resource) ->
    $resource 'api/claims/:claims', { claims:'@claims' }, {
        get:     { method: 'GET' }
      }
])