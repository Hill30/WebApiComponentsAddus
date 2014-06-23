angular.module('addus')
  .directive('appHeader', [
    '$log', 'userInfoResource'
    (console, userInfo) ->
      restrict:'AE'
      templateUrl: 'views/vendors/Addus/appHeaderTemplate.html'
      replace: true
      transclude: true
      link: (scope, element, attrs, controller) ->
        attrs.$observe "", () ->
          userInfo.get({}, (res) ->
            url = window.location.href.split("#")[0]
            console.log url
            scope.applications = res.availableApplications
            angular.forEach scope.applications, (value, key) ->
              if value.url == url
                scope.currentAppName = value.name            
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