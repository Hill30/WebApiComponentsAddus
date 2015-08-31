angular.module('addus').controller 'templatesController', [
	'$scope', '$rootScope', '$log', '$routeParams', '$location', 'debounce', 'popup', 'templatesResource', 'confirmation'
	($scope, $rootScope, console, $routeParams, $location, debounce, popup, templatesResource, confirmation) ->

		$rootScope.dismissNewARNotice() if typeof $rootScope.dismissNewARNotice is 'function'
		$rootScope.currentScreen = 'templates'

		$scope.templatesAdapter = {}
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
				templatesResource.list(options, success)

		forceDataAsyncLoad = () ->
			$scope.templatesAdapter.reload() if $scope.templatesAdapter.reload


		# pick, new, save, cancel, remove template

		$scope.pickTemplate = (template) ->
			$scope.originalTemplate = template
			$scope.pickedTemplate = angular.copy(template)
			$scope.isNew = false

		resetForm = () ->
			$scope.form.$setPristine()

		$scope.newTemplate = () ->
			resetForm()
			$scope.originalTemplate = null
			$scope.pickedTemplate = null
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
				popup.show
					type: 'success'
					text: "Template saved successfully."

		$scope.remove = () ->
			return if $scope.isNew or not $scope.pickedTemplate
			deleteConfirmationDialog = confirmation.configure
				title: 'Confirm deletion'
				text: 'Are you sure you want to remove this template?'
				confirmCaption: 'Remove'
				confirmAction: () ->
					templatesResource.remove { id: $scope.pickedTemplate.id }, () ->
						forceDataAsyncLoad()
						popup.show
							type: 'success'
							text: 'Template removed successfully.'
						$scope.pickedTemplate = null
			deleteConfirmationDialog.openDialog()


		# start program

		setFilterFromRouteParams()

]
