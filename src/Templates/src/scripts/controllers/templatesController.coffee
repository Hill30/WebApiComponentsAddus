angular.module('addus')
	.controller('templatesController', 
		['$scope', '$log', '$modal', '$routeParams', '$filter', '$location', '$rootScope', 'debounce', 'templateResource'
		($scope, console, $modal, $routeParams, $filter, $location, $rootScope, debounce, templateResource) ->
			
			revisionToRequestData = 0
			defaultDebounceTime = 350

			# work with route params

			refreshRouteParams = () ->
				$location.search if $scope.filter then { filter: $scope.filter } else {}

			setFilterFromRouteParams = () ->
				$scope.filter = $routeParams.filter if $routeParams.filter

			# search filter

			$scope.setFilterDebounced = debounce(() ->
				refreshRouteParams()
				forceDataAsyncLoad()
			, defaultDebounceTime, false)

			$scope.clearFilter = () ->
				$scope.filter = ''
				refreshRouteParams()
				forceDataAsyncLoad()

			# scroller datasource and data-reload implementation
			#templateResource.list({})

			$scope.templates =
				get: (index, count, success)->
					options = {}
					options.offset = index
					options.count = count
					options.filter = $scope.filter if $scope.filter

					successProccessed = (result) ->
						success(result)

					templateResource.list(options, successProccessed)

				revision: () ->
					revisionToRequestData

				loading: (value) ->
					$scope.isGridLoading = value

			forceDataAsyncLoad = () ->
				revisionToRequestData++

			# pick user

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
				return if not $scope.pickedTemplate or not $scope.pickedTemplate.id
				$scope.pickedTemplate.isNew = $scope.isNew

				templateResource.save $scope.pickedTemplate, (res) ->
					if not $scope.isNew
						$scope.originalTemplate[k] = v for k, v of $scope.pickedTemplate
					else
						forceDataAsyncLoad()
						$scope.pickedTemplate.id = res.id if res.id
					###
					$rootScope.popup.show
						type: 'success'
						text: "User saved successfully."
					###
					resetForm()
					$scope.isNew = false

			$scope.remove = () ->
				return if not $scope.pickedTemplate or not $scope.pickedTemplate.id
				templateResource.remove { id: $scope.pickedTemplate.id }, () ->
					forceDataAsyncLoad()
					$rootScope.popup.show
						type: 'success'
						text: "Group removed successfully."
					$scope.pickedTemplate = {}

			# start program
			setFilterFromRouteParams()
														
		])