angular.module('app').directive 'appHeader', [
	'$log', 'userInfoResource'
	(console, userInfo) ->

		restrict:'E'
		templateUrl: 'views/vendors/templates/appHeaderTemplate.html'
		replace: true
		transclude: true
		link: (scope, element, controller) ->
			userInfo.get({}, (res) ->
				scope.applications = res.availableApplications
				scope.login = res.login )
]

angular.module('app').directive 'appHeaderCurrentItem', [
	'$log','$location'
	(console, location) ->
		restrict:'A'
		link: (scope,element,attrs) ->

			scope.$watch (->location.$$url), (newLoc) ->
				if ((newLoc.split("/")[1]) == (element.attr("href").split("#")[1]))
					element.addClass "active"
				else
					element.removeClass "active"
]