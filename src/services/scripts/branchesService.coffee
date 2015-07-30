angular.module('app').factory('branchesService', [
	'$location', 'teamsResource'
	($location, teamsResource) ->

		instances = {}

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
			setIdList(instance, 'team', '')
			setNameList(instance, 'team', '')
			teamsResource.get {branches: getIdList(instance, 'branch')}, (res) ->
				item.name = item.displayString for item in res
				instance.scope.teams = res
				callback() if typeof callback is 'function'

		setFilters = (instance, options = {}) ->
			instance.scope.setFilter([
				{'label': 'branches', 'value': getIdList(instance, 'branch')},
				{'label': 'teams', 'value': getIdList(instance, 'team')}
			], null, { ignoreRouting: options.ignoreRouting })


		instance =

			initialize: (scope, resBranches, options = {}) ->
				self = this
				self.scope = scope
				return if not self.scope.branches = resBranches
				return if options.ignoreRouting
				if getEntitiesFromRouteParams(self, 'branch')
					firstBranchesLoading = true
					getTeams self, () ->
						firstTeamsLoading = true if getEntitiesFromRouteParams(self, 'team')

			reset: () ->
				self = this
				self.clearBranches()
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

			clearBranches: () ->
				self = this
				branchesCleaning = true
				setNameList(self, 'branch', '')
				setIdList(self, 'branch', '')
				self.scope.filters.branches = []
				self.scope.teams = undefined
				return self.clearTeams() if self.scope.filters.teams and self.scope.filters.teams.length
				setFilters(self)

			clearTeams: () ->
				self = this
				teamsCleaning = true
				setNameList(self, 'team', '')
				setIdList(self, 'team', '')
				self.scope.filters.teams = []
				setFilters(self)


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