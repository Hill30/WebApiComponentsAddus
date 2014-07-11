angular.module('addus').service('userInfoService', [
	'$log', '$q', 'userInfoResource'
	(console, $q, userInfoResource) ->
		userInfo = {}
		permissions = []
		isUserInfoInitialized = false

		isInitialized = () -> isUserInfoInitialized

		initializeAsync = () ->
			deffered = $q.defer()

			userInfoResource.get {}, (result) ->
				isUserInfoInitialized = true
				permissions = result.permissions
				userInfo = result
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
