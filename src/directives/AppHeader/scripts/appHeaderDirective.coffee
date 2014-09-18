angular.module('addus').directive('appHeader', [
	'$log', 'userInfoService'
	(console, userInfoService) ->
		restrict: 'AE'
		templateUrl: 'vendors/Addus/src/directives/AppHeader/views/appHeaderTemplate.html'
		replace: true
		transclude: true
		link: (scope, element, attrs, controller) ->
			userInfoService.initializeAsync().then (userInfo) ->
				scope.hasPermission = userInfoService.hasPermission
				scope.applications = userInfo.availableApplications
				scope.currentAppName = attrs.appName
				url = window.location.href.split("#")[0]
				for app in scope.applications
					scope.currentAppName = app.name if app.url is url
				scope.login = userInfo.login

])
.directive('appHeaderCurrentItem', [
		'$log', '$location'
		(console, location) ->
			restrict: 'A'
			link: (scope, element, attrs) ->
				scope.$watch (->
					location.$$url), (newLoc) ->
					attrHref = element.attr("href")
					attrHrefHash = attrHref.indexOf("\#")
					attrHrefClean = attrHref.substr(attrHrefHash + 1)

					urlPathDash = "_" + newLoc
					substrUrlLoc = urlPathDash.split(/\/|\?/)[1]

					if attrHrefClean == substrUrlLoc
						element.addClass "active"
					else
						element.removeClass "active"
	])