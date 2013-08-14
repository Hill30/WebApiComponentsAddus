addus_module = angular.module('addus', [])

addus_module.directive 'appHeader', [
  '$log', 'claimsService'
  (console, claims) ->

    restrict:'E'
    templateUrl: 'views/vendors/appHeader.html'
    replace: true
    transclude: true
    link: (scope, element, controller) ->
      claims.get({ claims: 'applications' }, (res) ->
        scope.applications = res.applications
        scope.userName = res.userName )
]

addus_module.directive 'appHeaderCurrentItem', [
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