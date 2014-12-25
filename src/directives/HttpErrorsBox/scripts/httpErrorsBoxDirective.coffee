angular.module('addus').directive('httpErrorsBox', ['$modal', ($modal) ->
	restrict: 'AE'
	templateUrl: 'vendors/Addus/src/directives/HttpErrorsBox/views/httpErrorsBoxTemplate.html'
	replace: true
	transclude: true
	link: (scope, element, attrs, controller) ->

		scope.httpErrorsBox = {}
		scope.httpErrorsBox.permissionDeniedDialog = {}

		isPermissionDeniedDialogOpened = false
		scope.httpErrorsBox.permissionDeniedDialog.openDialog  = () ->
			return if isPermissionDeniedDialogOpened
			isPermissionDeniedDialogOpened = true

			$modal.open({
				templateUrl: 'vendors/Addus/src/directives/HttpErrorsBox/views/permissionDeniedDialogTemplate.html',
				controller: ($scope, $modalInstance) ->
					$scope.reload = () ->
						location.reload()
					$scope.cancel = () ->
						$modalInstance.dismiss('cancel')
					$modalInstance.result.then null, () ->
						isPermissionDeniedDialogOpened = false
			})
])