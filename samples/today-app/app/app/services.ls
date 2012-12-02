'use strict'

const prefix = '/db/Today/collections'

# Services
(angular.module 'app.services', ['ngResource'])
  .factory 'List', <[$resource]> +++ ($resource) ->
    $resource prefix + '/List/:_id', {_id: '@_id'}, {
      update: {method: 'PUT'}
    }

