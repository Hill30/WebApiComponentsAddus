angular.module('addus').service('userInfoService', [
	'$log', '$q', 'userInfoResource'
	(console, $q, userInfoResource) ->
		userInfo = {}
		permissions = []
		isUserInfoInitialized = false
		userInfoInitializedResult = {}

		isInitialized = () -> isUserInfoInitialized

		initializeAsync = () ->
			deffered = $q.defer()

			if isUserInfoInitialized
				deffered.resolve(userInfoInitializedResult)
			else
				userInfoResource.get {}, (result) ->
					userInfo = result
					permissions = result.permissions
					isUserInfoInitialized = true
					userInfoInitializedResult = result
					deffered.resolve(result)

			deffered.promise

		getUserInfo = ->
			return userInfo

		permissionsList = ->
			return permissions

		hasPermission = (permission) ->
			return false if not permissions
			predicate = true for item in permissions when item is permission
			return predicate is true


		{
		isInitialized
		initializeAsync
		permissionsList
		getUserInfo
		hasPermission
		}
])
