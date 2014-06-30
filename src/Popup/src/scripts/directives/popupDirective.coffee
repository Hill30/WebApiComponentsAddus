angular.module('addus')
	.directive('popup', ['$timeout', ($timeout) ->
		restrict: 'AE'
		templateUrl: 'views/vendors/Addus/popupTemplate.html'
		replace: true
		transclude: true
		link: ($scope, element, attrs, controller) ->
			$scope.popup = {}
			$scope.popup.list = []
			popupIdLast = 0
			ttlDefault = 1500

			$scope.popup.show = (popupObj) ->
				popupIdLast++
				popupObj.id = popupIdLast
				if not popupObj.doNotHide
					$timeout(() ->
						$scope.popup.close popupObj
					, popupObj.ttl || ttlDefault)
				$scope.popup.list.push popupObj

			$scope.popup.close = (popupObj) ->
				for item, index in $scope.popup.list
					if item.id is popupObj.id
						$scope.popup.list.splice index, 1
						break

	])