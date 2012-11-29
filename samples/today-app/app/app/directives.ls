# Directive

# Create an object to hold the module.


# register the module with Angular
angular.module 'app.directives' [ 'app.services' ]
.directive ngBlur: ->
    (scope, elem, attrs) ->
        elem.bind 'blur', ->
            scope.$apply attrs.ngBlur

.directive appVersion: <[version]> +++ (version) ->
  (scope, elm, attrs) ->
    elm.text version
