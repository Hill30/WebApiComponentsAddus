angular.module('addus').controller 'templatesController', [
	'$scope', '$rootScope', '$log', '$routeParams', '$location', 'debounce', 'templatesResource'
	($scope, $rootScope, console, $routeParams, $location, debounce, templatesResource) ->

		$rootScope.dismissNewARNotice()
		$rootScope.currentScreen = 'templates'


		revisionToRequestData = 0
		defaultDebounceTime = 350


		# work with route params

		refreshRouteParams = () ->
			$location.search if $scope.nameFilter then { nameFilter: $scope.nameFilter } else {}

		setFilterFromRouteParams = () ->
			$scope.nameFilter = $routeParams.nameFilter if $routeParams.nameFilter


		# search filter

		$scope.setFilterDebounced = debounce(() ->
			refreshRouteParams()
			forceDataAsyncLoad()
		, defaultDebounceTime, false)

		$scope.clearFilter = () ->
			$scope.nameFilter = ''
			refreshRouteParams()
			forceDataAsyncLoad()


		# scroller datasource and data-reload implementation

		$scope.templates =
			get: (index, count, success) ->
				options = {}
				options.offset = index
				options.count = count
				options.nameFilter = $scope.nameFilter if $scope.nameFilter

				successProccessed = (result) ->
					success(result)

				templatesResource.list(options, successProccessed)

			revision: () ->
				revisionToRequestData

		forceDataAsyncLoad = () ->
			revisionToRequestData++


		# pick, new, save, cancel, remove template

		$scope.pickTemplate = (template) ->
			$scope.originalTemplate = template
			$scope.pickedTemplate = angular.copy(template)
			$scope.isNew = false

		resetForm = () ->
			$scope.form.$setPristine()

		$scope.newTemplate = () ->
			resetForm()
			$scope.pickedTemplate = {}
			$scope.isNew = true

		$scope.cancel = () ->
			$scope.pickTemplate($scope.originalTemplate)
			resetForm()

		$scope.save = () ->
			return if not $scope.pickedTemplate

			templatesResource.save $scope.pickedTemplate, (res) ->
				forceDataAsyncLoad()
				$scope.pickedTemplate.id = res.id if $scope.isNew and res.id
				$scope.isNew = false
				resetForm()

				if $rootScope.popup and $rootScope.popup.show
					$rootScope.popup.show
						type: 'success'
						text: "Template saved successfully."

		$scope.remove = () ->
			return if not $scope.pickedTemplate
			templatesResource.remove { id: $scope.pickedTemplate.id }, () ->
				forceDataAsyncLoad()
				$rootScope.popup.show
					type: 'success'
					text: "Template removed successfully."
				$scope.pickedTemplate = {}


		# start program

		setFilterFromRouteParams()

]