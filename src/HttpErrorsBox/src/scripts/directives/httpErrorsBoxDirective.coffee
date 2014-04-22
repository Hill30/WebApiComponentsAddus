angular.module('addus')
	.directive('httpErrorsBox', ['$modal', '$rootScope', ($modal, $rootScope) ->
		restrict: 'AE'
		templateUrl: 'views/vendors/Addus/httpErrorsBoxTemplate.html'
		replace: true
		transclude: true
		link: (scope, element) ->

			alertHiderElement = element.find('[data-hide-button]')
			dialogOpenerElement = element.find('#403DialogOpener')

			hideAlert = () ->
				element.css('display', 'none')

			openDialog = () ->

				return if $rootScope.is403DialogOpened
				$rootScope.is403DialogOpened = true
				
				modalInstance = $modal.open({
					templateUrl: 'views/vendors/Addus/403DialogTemplate.html',
					controller: ($scope, $modalInstance) ->
						$scope.reload = () ->
							location.reload()
						$scope.cancel = () ->
							$modalInstance.dismiss('cancel')
				})

				modalInstance.result.then () ->
					$rootScope.is403DialogOpened = false
				, () ->
					$rootScope.is403DialogOpened = false


			alertHiderElement.bind 'click', hideAlert
			dialogOpenerElement.bind 'click', openDialog

			scope.$on "$destroy", () ->
				alertHiderElement.unbind 'click', hideAlert
				dialogOpenerElement.unbind 'click', openDialog
	])