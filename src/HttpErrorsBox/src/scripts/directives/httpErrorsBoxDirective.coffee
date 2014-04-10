angular.module('addus')
	.directive('httpErrorsBox', () ->
		restrict: 'AE'
		templateUrl: 'views/vendors/Addus/httpErrorsBoxTemplate.html'
		replace: true
		transclude: true
		link: (scope, element, attrs, controller) ->

			hideButtonElemnt = element.find('[data-hide-button]')

			hideBox = () ->
				element.css('display', 'none')

			hideButtonElemnt.bind 'click', hideBox

			scope.$on "$destroy", () ->
				hideButtonElemnt.unbind 'click', hideBox
	)