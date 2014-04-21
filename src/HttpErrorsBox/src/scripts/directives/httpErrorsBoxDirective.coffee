angular.module('addus')
	.directive('httpErrorsBox', ['$modal', ($modal) ->
		restrict: 'AE'
		templateUrl: 'views/vendors/Addus/httpErrorsBoxTemplate.html'
		replace: true
		transclude: true
		link: (scope, element, attrs, controller) ->

			alertHiderElement = element.find('[data-hide-button]')
			dialogOpenerElement = element.find('#permissionDeniedDialogOpener')

			hideAlert = () ->
				element.css('display', 'none')

			openDialog = () ->
				$modal.open({
					templateUrl: 'views/vendors/Addus/permissionDeniedDialogTemplate.html',
					controller: ($scope, $modalInstance) ->
						$scope.reload = () ->
							location.reload()
						$scope.cancel = () ->
							$modalInstance.dismiss('cancel')
				})

			alertHiderElement.bind 'click', hideAlert
			dialogOpenerElement.bind('click', openDialog)

			scope.$on "$destroy", () ->
				alertHiderElement.unbind 'click', hideAlert
				dialogOpenerElement.unbind('click', openDialog)
	])