angular.module('addus').controller 'templatesController', [
	'$scope', '$log', '$rootScope',
	($scope, console, $rootScope) ->
		$rootScope.dismissNewARNotice()
		$rootScope.currentScreen = 'templates'
		console.log "start templates"
]