angular.module('addus')
	.directive('httpErrorsBox', ['$modal', ($modal) ->
		restrict: 'AE'
		templateUrl: 'views/vendors/Addus/httpErrorsBoxTemplate.html'
		replace: true
		transclude: true
		link: (scope, element, attrs, controller) ->

			dialogOpenerElement = element.find('#permissionDeniedDialogOpener')

			openDialog = () ->
				$modal.open({
					templateUrl: 'views/vendors/Addus/permissionDeniedDialogTemplate.html',
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