# Declare app level module which depends on filters, and services
App = angular.module \app <[ngCookies ngResource app.controllers app.directives app.filters app.services]>

App.config <[$routeProvider $locationProvider]> +++ ($routeProvider, $locationProvider, config) ->
  $routeProvider
    .when \/list/:listUuid templateUrl: \/partials/app/list.html
    .when \/list/ templateUrl: \/partials/app/list.html
    # Catch all
    .otherwise redirectTo: \/list

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode false