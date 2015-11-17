angular.module('addus').factory('userProfileService', [
	'$q', '$location', '$route', 'userInfoResource', 'userSettingsResource'
	($q, $location, $route, userInfoResource, userSettingsResource) ->

		self = {}

		### userInfo ###

		userInfo = {}
		permissions = []
		isUserInfoInitialized = false
		userInfoInitializedResult = {}

		self.isInitialized = () -> isUserInfoInitialized

		self.initializeAsync = () ->
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

		self.getUserInfo = -> userInfo

		self.getPermissions = -> permissions

		self.hasPermission = (permission) ->
			return false if not permissions
			predicate = true for item in permissions when item is permission
			return predicate is true


		### userSettings ###

		userSettings = {}

		getRouteParamsToSave = (options = {}) ->
			routeParams = $location.search()
			if options.include and options.include.length
				newRouteParams = {}
				for token in options.include
					newRouteParams[token] = routeParams[token] if routeParams[token]
				routeParams = newRouteParams
			if options.exclude and options.exclude.length
				delete routeParams[token] for token in options.exclude
			routeParams

		loadUserSettingsDone = (callback) ->
			self.isUserSettingsLoading = false
			callback() if typeof callback is 'function'

		filterUserSettings = () ->
			return if not angular.isObject userSettings
			for key, val of userSettings
				delete userSettings[key] if val is ''

		# options:
		# doNotPassEmptyValues -- if true then empty params ('') will be removed from result
		# setToRoute -- if true then result params will be set route params
		# routeReload -- if true then the route will reload
		# post -- a callback to execute after a response from remote (good or bad) is arrived
		self.loadUserSettings = (options = {}) ->
			self.isUserSettingsLoading = true
			userSettingsResource.get {}, (result) ->
				angular.copy(result, userSettings)
				delete userSettings.$promise
				delete userSettings.$resolved
				filterUserSettings() if options.doNotPassEmptyValues
				$location.search userSettings if options.setToRoute
				$route.reload() if options.routeReload
				loadUserSettingsDone(options.post)
			, -> loadUserSettingsDone(options.post)

		self.getUserSettings = -> userSettings

		saveUserSettingsDone = (callback) ->
			self.isUserSettingsSaving = false
			callback() if typeof callback is 'function'

		# options:
		# include -- array of string props which will be taken from route params (only!)
		# exclude -- array of string props which will not be taken from route params
		# post -- a callback to execute after a response from remote (good or bad) is arrived
		self.saveUserSettings = (options = {}) ->
			self.isUserSettingsSaving = true
			settings = getRouteParamsToSave(options)
			userSettingsResource.post settings, (res) ->
				saveUserSettingsDone(options.post)
			, -> saveUserSettingsDone(options.post)

		return self
])