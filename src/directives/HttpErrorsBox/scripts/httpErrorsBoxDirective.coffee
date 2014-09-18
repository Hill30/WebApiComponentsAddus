angular.module('addus')
	.directive('httpErrorsBox', ['$modal', ($modal) ->
		restrict: 'AE'
		templateUrl: 'vendors/Addus/directives/HttpErrorsBox/views/httpErrorsBoxTemplate.html'
		replace: true
		transclude: true
		link: (scope, element, attrs, controller) ->

			dialogOpenerElement = element.find('#permissionDeniedDialogOpener')

			openDialog = () ->
				$modal.open({
					templateUrl: 'vendors/Addus/directives/HttpErrorsBox/views/permissionDeniedDialogTemplate.html',
					controller: ($scope, $modalInstance) ->
						$scope.reload = () ->
							location.reload()
						$scope.cancel = () ->
							$modalInstance.dismiss('cancel')
				})

			dialogOpenerElement.bind('click', openDialog)

			scope.$on "$destroy", () ->
				dialogOpenerElement.unbind('click', openDialog)
	])