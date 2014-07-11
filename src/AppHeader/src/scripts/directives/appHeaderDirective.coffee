angular.module('addus')
  .directive('appHeader', [
    '$log', 'userInfoService'
    (console, userInfoService) ->
      restrict:'AE'
      templateUrl: 'views/vendors/Addus/appHeaderTemplate.html'
      replace: true
      transclude: true
      link: (scope, element, attrs, controller) ->
        attrs.$observe "", () ->
          userInfoService.getUserInfo().then((res) ->
            url = window.location.href.split("#")[0]
            console.log url
            scope.applications = res.availableApplications
            isFound = false
            angular.forEach scope.applications, (value, key) ->
              if value.url == url
                isFound = true
                scope.currentAppName = value.name
            unless isFound
              scope.currentAppName = attrs.appName             
            scope.login = res.login
          )
  ])
  .directive('appHeaderCurrentItem', [
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
  ])