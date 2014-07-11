angular.module('addus').service('userInfoService', [
	'$log', '$q', 'userInfoResource'
	(console, $q, userInfoResource) ->
		userInfo = {}
		permissions = []
		isInitialized = false

		getUserInfoAsync = () ->
			deffered = $q.defer()

			userInfoResource.get {}, (result) ->
				isInitialized = true
				permissions = result.permissions
				userInfo = result
				deffered.resolve(result)

			deffered.promise


		initializeAsync = () ->
			getUserInfoAsync()

		hasPermission = (permission) ->
			return false if not permissions
			predicate = true for item in permissions when item is permission
			return predicate is true

		getUserInfo = ->
			return userInfo if isInitialized
			return getUserInfoAsync()

		permissionsList = ->
			return permissions


		{
		initializeAsync
		hasPermission
		permissionsList
		getUserInfo
		}
])
