describe "directives", ->
  elm = undefined
  scope = undefined
  $httpBackend = null

  beforeEach module('app')

  beforeEach inject(($rootScope, $controller, $compile, $templateCache, $injector) ->



    $httpBackend = $injector.get("$httpBackend")
    $httpBackend.whenGET("api/claims/applications").respond respondData
    $templateCache.put('views/directives/appHeader.html', '
        <header>
            <div class="navbar navbar-fixed-top">
                <div class="navbar-inner">
                    <div class="container">
                        <div class="row">
                            <div class="span2">
                                <div class="dropdown">
                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">Admin Tools <b class="caret"></b></a>
                                    <ul class="dropdown-menu">
                                      <li ng-repeat="application in applications"><a ng-href="{{application.url}}">{{application.name}}</a></li>
                                    </ul>
                                </div>
                            </div>

                            <div class="span6">
                                <ul class="nav" ng-transclude>
                                </ul>
                            </div>

                            <div class="span4">
                                <div class="user pull-right">
                                    <span class="user-name">{{userName}}</span>
                                    <button type="submit" class="btn">Sign out <span class="icon-signout"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>     ')

    respondData =
      userName: "John Smith"
      applications: [
        name: "Admin Tool"
        url: "Admin"
      ,
        name: "BestFit"
        url: "bestfit"
      ]

    $rootScope.applications = respondData.applications
    $rootScope.userName = respondData.userName
  )

  describe "app-header", ->
    it "should de exist", inject(($compile, $rootScope) ->

      sandbox = angular.element('<div></div>');
      dir = angular.element('<app-header></app-header>')
      sandbox.append(dir)
      $compile(dir)($rootScope)
      $rootScope.$digest()
      expect(dir).toBe
    )

  describe "admin tools dropdown elements", ->
    it "should de exist", inject(($compile, $rootScope) ->
      sandbox = angular.element('<ul></ul>');
      li = angular.element('<li ng-repeat="application in applications"><a ng-href="{{application.url}}">{{application.name}}</a></li>')

      sandbox.append(li)

      $compile(li)($rootScope)
      $rootScope.$digest()

      expect(sandbox.children().length).toBeGreaterThan(0)
    )

  describe "user name", ->
    it "should de exist", inject(($compile, $rootScope) ->
      sandbox = angular.element('<div></div>');
      span = angular.element('<span class="user-name">{{userName}}</span>')

      sandbox.append(span)
      $compile(span)($rootScope)
      $rootScope.$digest()

      expect(sandbox.children()).toBe
      expect(sandbox.children().text()).not.toMatch(/^\s+$/)
      expect(sandbox.children().text().length).toBeGreaterThan(0)
    )