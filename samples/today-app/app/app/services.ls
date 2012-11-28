'use strict'

const prefix = '/db/Today/collections'

# Services
((angular.module 'app.services', ['ngResource']).value 'version', '0.1')
  .factory 'List', <[$resource]> +++ ($resource) ->
    $resource prefix + '/List/:_id', {_id: '@_id'}, {
      create: {method: 'POST'}
      show: {method: 'GET'}
      update: {method: 'PUT'}
      destroy: {method: 'DELETE'}
    }
  .factory 'Task', <[$resource]> +++ ($resource) ->
    $resource prefix + '/List/:_List/tasks/:_id', {_id: '@_id'}, {
      index: { method: 'GET', isArray: true },
      create: {method: 'POST'}
      show: {method: 'GET'}
      update: {method: 'PUT'}
      destroy: {method: 'DELETE'}
    }

