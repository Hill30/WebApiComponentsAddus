angular.module('addus').directive 'templates', [
	'$log', '$routeParams', '$location', 'debounce', 'templatesResource'
	(console, $routeParams, $location, debounce, templatesResource) ->
			
		restrict: "E"
		replace: true
		transclude: true
		template: '
<div class="main-container">
<div class="row">
<div class="col-sm-3">
	<div class="aside">
		<div class="filters filters-users-page" ng-class="{\'element-disabled\': false}">
			<form>
				<fieldset>
					<div class="form-group form-group-section">
						<label class="control-label">
							<span class="glyphicon glyphicon-search"></span> Templates:
							<button class="pull-right btn btn-xs btn-primary" ng-click="newTemplate()" ng-disabled="false">
								<span class="glyphicon glyphicon-plus"></span>
							</button>
						</label>
						<div class="form-group">
							<div class="row">
								<div class="col-xs-11">
									<input
											placeholder="Search"
											class="form-control input-sm"
											type="text"
											ng-model="nameFilter"
											ng-change="setFilterDebounced()"
											ng-disabled="false"
											name="name">
								</div>
								<div class="col-xs-1 text-center">
									<a ng-click="clearFilter()" class="control-remove" tabindex="-1">
										<span class="glyphicon glyphicon-remove-2"></span>
									</a>
								</div>
							</div>
						</div>
					</div>
					<div class="search-results">
						<div ui-scroll-viewport class="search-results-scroll" style="width: 200px; height: 300px; display: block; background-color: white;">
							<div class="search-results-item-wrap" ui-scroll="t in templates" is-loading="loading">
								<span class="search-results-item"
									  ng-class="{active: !isNew && t.id == pickedTemplate.id}"
									  ng-click="pickTemplate(t)">{{t.name}}</span>
							</div>
						</div>
					</div>
				</fieldset>
			</form>
		</div>
	</div>
</div>
<div class="col-sm-6">
	<div class="form-messages" ng-class="{\'element-disabled\': !pickedTemplate}">
		<form name="form" novalidate>
			<div class="form-horizontal" role="form">
				<div class="form-group">
					<label for="id" class="col-sm-4 control-label">Id:</label>
					<div class="col-sm-8">
						<input
								class="form-control"
								type="text"
								ng-disabled="!pickedTemplate"
								ng-model="pickedTemplate.id"
								id="templateId"
								required><span class="required-flag"></span>
					</div>
				</div>
				<div class="form-group">
					<label for="name" class="col-sm-4 control-label">Name:</label>
					<div class="col-sm-8">
						<input
								class="form-control"
								type="text"
								ng-disabled="!pickedTemplate"
								ng-model="pickedTemplate.name"
								id="templateName"
								required><span class="required-flag"></span>
					</div>
				</div>
				<div class="form-group">
					<label for="description" class="col-sm-4 control-label">Description:</label>
					<div class="col-sm-8">
						<input
								class="form-control"
								type="text"
								ng-disabled="!pickedTemplate"
								ng-model="pickedTemplate.description"
								id="description">
					</div>
				</div>
				<div class="form-group">
					<label for="text" class="col-sm-4 control-label">Text:</label>
					<div class="col-sm-8">
						<textarea
								class="form-control"
								type="text"
								ng-disabled="!pickedTemplate"
								ng-model="pickedTemplate.text"
								id="text"
								required>
						</textarea><span class="required-flag"></span>
					</div>
				</div>
			</div>
			<div class="form-actions">
				<div class="row">
					<div class="col-sm-6">
						<button class="btn btn-default" ng-disabled="!pickedTemplate" ng-click="remove()">
							Remove <span class="glyphicon glyphicon-remove-2"></span>
						</button>
					</div>
					<div class="col-sm-6 text-right">
						<button class="btn btn-default" ng-click="cancel()" ng-disabled="!form.$dirty">Cancel</button>
						<button class="btn btn-primary" type="submit" ng-disabled="form.$invalid || !form.$dirty"
								ng-click="save()">
							Save <span class="glyphicon glyphicon-checkmark-2"></span>
						</button>
					</div>
				</div>
			</div>
		</form>
	</div>
</div>
</div>
</div>'

		controller: ($scope, $rootScope) ->
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
			#templateResource.list({})

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

				templatesResource.save $scope.pickedTemplate, (res) ->
					if not $scope.isNew
						$scope.originalTemplate[k] = v for k, v of $scope.pickedTemplate
					else
						forceDataAsyncLoad()
						$scope.pickedTemplate.id = res.id if res.id
					
					$rootScope.popup.show
						type: 'success'
						text: "Template saved successfully."
					
					resetForm()
					$scope.isNew = false

			$scope.remove = () ->
				return if not $scope.pickedTemplate or not $scope.pickedTemplate.id
				templatesResource.remove { id: $scope.pickedTemplate.id }, () ->
					forceDataAsyncLoad()
					$rootScope.popup.show
						type: 'success'
						text: "Template removed successfully."
					$scope.pickedTemplate = {}
			
			return {
				setFilterFromRouteParams: setFilterFromRouteParams
			}

		link: (scope, element, attrs, controller) ->
			###
			error = (text) -> console.error "Association directive: " + text
			return error "No 'options'-attr" if not attrs.options
			scope.options = options = scope.$parent[attrs.options]
			return error "No '" + attrs.options + "' within scope" if not options
			return error "No 'container' property within 'options'-attr" if not options.container
			return error "No 'entities' property within 'options'-attr" if not options.entities
			return error "No 'addedArray' property within 'options'-attr" if not options.addedArray
			return error "No 'deletedArray' property within 'options'-attr" if not options.deletedArray
			return error "No 'resourceList' property within 'options'-attr" if not options.resourceList
			scope.entityOutputToken = if options.entityOutputToken then options.entityOutputToken else 'name'
			###
			controller.setFilterFromRouteParams()
													
]