angular.module('addus').directive('httpErrorsBox', ['$modal', ($modal) ->
	restrict: 'AE'
	templateUrl: 'vendors/Addus/src/directives/HttpErrorsBox/views/httpErrorsBoxTemplate.html'
	replace: true
	transclude: true
	link: (scope, element, attrs, controller) ->
		isOpened = false
		dialogOpenerElement = element.find('#permissionDeniedDialogOpener')

		openDialog = () ->
			return if isOpened
			isOpened = true

			$modal.open({
				templateUrl: 'vendors/Addus/src/directives/HttpErrorsBox/views/permissionDeniedDialogTemplate.html',
				controller: ($scope, $modalInstance) ->
					$scope.reload = () ->
						location.reload()
					$scope.cancel = () ->
						$modalInstance.dismiss('cancel')
					$modalInstance.result.then null, () ->
						isOpened = false
			})

		dialogOpenerElement.bind('click', openDialog)

		scope.$on "$destroy", () ->
			dialogOpenerElement.unbind('click', openDialog)
])