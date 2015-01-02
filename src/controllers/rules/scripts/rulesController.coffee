angular.module('addus').controller 'rulesController', [
	'$scope', '$rootScope', '$routeParams', '$location', 'debounce', 'popup', 'rulesResource'
	($scope, $rootScope, $routeParams, $location, debounce, popup, rulesResource) ->

		$rootScope.dismissNewARNotice()

		revisionToRequestData = 0
		defaultDebounceTime = 350
		$scope.shared = {}


		# work with route params

		refreshRouteParams = () ->
			$location.search if $scope.shared.nameFilter then { nameFilter: $scope.shared.nameFilter } else {}

		setFilterFromRouteParams = () ->
			$scope.shared.nameFilter = $routeParams.nameFilter if $routeParams.nameFilter


		# search filter

		$scope.setFilterDebounced = debounce(() ->
			refreshRouteParams()
			forceDataAsyncLoad()
		, defaultDebounceTime, false)

		$scope.clearFilter = () ->
			$scope.shared.nameFilter = ''
			refreshRouteParams()
			forceDataAsyncLoad()


		# scroller datasource and data-reload implementation

		$scope.rules =
			get: (index, count, success)->
				options = {}
				options.offset = index - 1
				options.count = count
				options.nameFilter = $scope.shared.nameFilter if $scope.shared.nameFilter

				successProccessed = (result) ->
					success(result)

				rulesResource.list(options, successProccessed)

			revision: ->
				revisionToRequestData

		forceDataAsyncLoad = () ->
			revisionToRequestData++


		# pick rule

		$scope.pickRule = (rule) ->
			$scope.isNew = false
			$scope.originalRule = rule
			$scope.pickedRule = angular.copy(rule)
			pRule = $scope.pickedRule

			pRule.usingsAsText = ''
			pRule.usingsAsText += using + '\n' for using in rule.ruleSource.usings
			pRule.usingsAsText = pRule.usingsAsText.trim()

			pRule.requiresAsText = ''
			pRule.requiresAsText += assembly + '\n' for assembly in rule.ruleSource.requires
			pRule.requiresAsText = pRule.requiresAsText.trim()

			tmpDate = moment(pRule.ruleSource.updatedAt).format('MM/DD/YYYY')
			sTime = moment(pRule.ruleSource.updatedAt).format('h:mm a')
			pRule.updatedAtAsString = tmpDate + " " + sTime


		# activate/save/cancel picked rule

		resetForm = () ->
			$scope.ruleForm = $('form[name="ruleForm"]').eq(0).controller('form')
			$scope.ruleForm.$setPristine()

		$scope.cancel = () ->
			$scope.pickRule($scope.originalRule)
			resetForm()

		$scope.newRule = () ->
			resetForm()
			$scope.pickedRule = {}
			$scope.isNew = true

		getRuleSaveObject = (rule) ->
			id: rule.id
			name: rule.name
			isActive: rule.isActive
			properties: rule.propertiesDefaultValues
			usings: rule.usingsAsText
			text: rule.ruleSource.ruleText

		processChanges = (result) ->
			if result.failed
				popup.show
					type: 'warning'
					text: "Rule compilation " + result.message
					ttl: -1
				return
			forceDataAsyncLoad()
			$scope.pickedRule = null
			resetForm()
			$scope.isNew = false
			popup.show
				type: 'success'
				text: "Rule saved successfully."

		$scope.save = () ->
			return if not $scope.pickedRule
			$scope.pickedRule.isNew = $scope.isNew
			rulesResource.save getRuleSaveObject($scope.pickedRule), processChanges

		$scope.activate = () ->
			return if not $scope.pickedRule
			$scope.pickedRule.isNew = $scope.isNew
			rulesResource.activate {id: $scope.pickedRule.id, activate: !$scope.pickedRule.isActive }, processChanges


		# start program

		setFilterFromRouteParams()

]