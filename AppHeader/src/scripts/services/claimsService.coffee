addus_module.service('claimsService',[
    '$log','$resource',
    (console, $resource) ->
      Claims = $resource 'api/claims/:claims'
      get = (claims) ->
        Claims.get {claims: claims}

      {
        get
      }
  ])