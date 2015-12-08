angular.module('addus').factory('branchesService', [
	'$location', 'teamsResource', '$q'
	($location, teamsResource, $q) ->

		instances = {}
		teamsCache = []

		firstBranchesLoading = false
		firstTeamsLoading = false
		branchesCleaning = false
		teamsCleaning = false

		capitalize = (string) -> string.charAt(0).toUpperCase() + string.slice(1)
		getListToken = (instance, entityToken, fieldToken) ->
			instance.instanceToken + '_' + entityToken + capitalize(fieldToken) + 'ListString'
		getIdList = (instance, entityToken) ->
			instance.scope[getListToken(instance, entityToken, 'id')]
		setIdList = (instance, entityToken, value) ->
			instance.scope[getListToken(instance, entityToken, 'id')] = value
		getNameList = (instance, entityToken) ->
			instance.scope[getListToken(instance, entityToken, 'name')]
		setNameList = (instance, entityToken, value) ->
			instance.scope[getListToken(instance, entityToken, 'name')] = value

		getEntitiesFromRouteParams = (instance, entityToken) ->
			if entityToken is 'branch'
				listToken = 'branches'
			else if entityToken is 'team'
				listToken = 'teams'
			else return
			return if not (idListStr = $location.search()[listToken])
			idList = idListStr.split(',')
			nameListStr = ''
			result = []
			for item in instance.scope[listToken]
				if idList.indexOf(item.id.toString()) isnt -1
					result.push item
					nameListStr += (if nameListStr.length > 1 then ', ' else '') + item.name
			setIdList(instance, entityToken, idListStr)
			setNameList(instance, entityToken, nameListStr)
			instance.scope.filters[listToken] = result
			true

		setIdAndNameLists = (instance, entityToken) ->
			if entityToken is 'branch'
				list = instance.scope.filters.branches
			else if entityToken is 'team'
				list = instance.scope.filters.teams
			else return
			idStr = nameStr = ''
			for item in list
				idStr += (if idStr.length then ',' else '') + item.id
				nameStr += (if nameStr.length then ', ' else '') + item.name
			setIdList(instance, entityToken, idStr)
			setNameList(instance, entityToken, nameStr)
			true

		getTeams = (instance, callback) ->
			if not getIdList(instance, 'branch')
				instance.scope.teams = undefined
				return

			branchIdList = getIdList(instance, 'branch')

			# a duplicate request while original one is still pending (and not in cache)
			if instance.teamsRequest and instance.teamsRequest.branchIdList is branchIdList and instance.teamsRequest.promise.$$state.status is 0
				return

			setIdList(instance, 'team', '')
			setNameList(instance, 'team', '')
			instance.scope.teams = []

			processTeamsResult = (teamsResult) ->
				item.name = item.displayString for item in teamsResult
				instance.scope.teams = teamsResult
				callback() if typeof callback is 'function'

			for item in teamsCache
				if item.branchIdList is branchIdList
					processTeamsResult(item.teams)
					return

			instance.teamsRequest = { branchIdList: branchIdList }
			instance.teamsRequest.promise = teamsResource.get({branches: branchIdList}, (teamsResult) ->
				teamsCache.push
					branchIdList: branchIdList
					teams: teamsResult
				processTeamsResult(teamsResult)
			).$promise

		setFilters = (instance, options = {}) ->
			return if !instance.hasInitialized
			setFilterOptions = {}
			angular.extend(setFilterOptions, options)
			setFilterOptions.ignoreRouting = instance.options.ignoreRouting
			instance.scope.setFilter([
				{'label': 'branches', 'value': getIdList(instance, 'branch')},
				{'label': 'teams', 'value': getIdList(instance, 'team')}
			], null, setFilterOptions)


		instance =

			initialize: (scope, resBranches, options = {}) ->
				self = this
				self.hasInitialized = false
				initDone = -> self.hasInitialized = true

				self.scope = scope
				self.scope.branches = resBranches
				self.options = options
				return initDone() if not self.scope.branches
				return initDone() if self.options.ignoreRouting

				if getEntitiesFromRouteParams(self, 'branch')
					if $location.search()['teams']
						scope.setFilter([
							{'label': 'branches', 'value': $location.search()['branches']},
							{'label': 'teams', 'value': $location.search()['teams']}
						], null, { ignoreRouting: true })
						return getTeams self, ->
							firstTeamsLoading = true if (getEntitiesFromRouteParams(self, 'team'))
							initDone()

				return initDone()

			reset: (options) ->
				self = this
				self.clearBranches(options)
				firstBranchesLoading = false
				firstTeamsLoading = false
				branchesCleaning = false
				teamsCleaning = false

			getBranchNameListToken: -> getListToken(this, 'branch', 'name')
			getTeamNameListToken: -> getListToken(this, 'team', 'name')

			setBranch: () ->
				self = this
				return if firstTeamsLoading
				return branchesCleaning = false if branchesCleaning
				return if not setIdAndNameLists(self, 'branch')
				getTeams(self, null)
				return firstBranchesLoading = false if firstBranchesLoading
				return self.clearTeams() if self.scope.filters.teams and self.scope.filters.teams.length
				setFilters(self)

			setTeam: () ->
				self = this
				return teamsCleaning = false if teamsCleaning
				return if not setIdAndNameLists(self, 'team')
				return firstTeamsLoading = false if firstTeamsLoading
				setFilters(self)

			clearBranches: (options) ->
				self = this
				return if !self.scope.filters.branches or !self.scope.filters.branches.length
				branchesCleaning = true
				setNameList(self, 'branch', '')
				setIdList(self, 'branch', '')
				self.scope.filters.branches = []
				self.scope.teams = undefined
				return self.clearTeams(options) if self.scope.filters.teams and self.scope.filters.teams.length
				setFilters(self, options)

			clearTeams: (options) ->
				self = this
				return if !self.scope.filters.teams or !self.scope.filters.teams.length
				teamsCleaning = true
				setNameList(self, 'team', '')
				setIdList(self, 'team', '')
				self.scope.filters.teams = []
				setFilters(self, options)


		instanceToExtend =
			initialize: instance.initialize
			reset: instance.reset
			getBranchNameListToken: instance.getBranchNameListToken
			getTeamNameListToken: instance.getTeamNameListToken
			setBranch: instance.setBranch
			setTeam: instance.setTeam
			clearBranches: instance.clearBranches
			clearTeams: instance.clearTeams

		return {
		instance: (token = 'defaultInstance') ->
			result = instances[token]
			return result if angular.isObject(result)
			result = angular.extend({}, instanceToExtend)
			result.instanceToken = token
			result.scope = null
			result
		}
])