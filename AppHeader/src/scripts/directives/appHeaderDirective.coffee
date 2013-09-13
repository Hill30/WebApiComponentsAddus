addus_module.directive 'appHeader', [
	'$log', 'userInfoResource'
	(console, userInfo) ->

		restrict:'AE'
		templateUrl: 'views/vendors/templates/appHeaderTemplate.html'
		replace: true
		transclude: true
		link: (scope, element, controller) ->
			userInfo.get({}, (res) ->
				scope.applications = res.availableApplications
				scope.currentAppName = scope.applications[0].name || 'Apps'
				scope.login = res.login )
]

addus_module.directive 'appHeaderCurrentItem', [
	'$log','$location'
	(console, location) ->
		restrict:'A'
		link: (scope,element,attrs) ->

			scope.$watch (->location.$$url), (newLoc) ->				

				attrHref =  element.attr("href")
				attrHrefHash = attrHref.indexOf("\#")
				attrHrefClean =  attrHref.substr(attrHrefHash+1)

				urlPathDash = "_" + newLoc
				substrUrlLoc = urlPathDash.split(/\/|\?/)[1]

				if attrHrefClean == substrUrlLoc
				  element.addClass "active"
				else
					element.removeClass "active"
]