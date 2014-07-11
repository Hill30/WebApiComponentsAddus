angular.module('addus').service('userInfoService', [
	'$log', '$q', 'userInfoResource'
	(console, $q, userInfoResource) ->
		userInfo = {}
		permissions = []
		isInitialized = false

		isInitialized = () -> isInitialized

		initializeAsync = () ->
			deffered = $q.defer()

			userInfoResource.get {}, (result) ->
				isInitialized = true
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
