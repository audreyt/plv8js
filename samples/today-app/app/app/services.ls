'use strict'

const prefix = '/databases/today/'

# Services
((angular.module 'app.services', ['ngResource']).value 'version', '0.1')
  .factory 'List', <[$resource]> +++ ($resource) ->
    $resource prefix + 'collections/list/:listUuid', {listUuid: '@listUuid'}, {
      create: {method: 'POST'}
      show: {method: 'GET'}
      update: {method: 'PUT'}
      destroy: {method: 'DELETE'}
    }
  .factory 'Task', <[$resource]> +++ ($resource) ->
    $resource prefix + '/list/:listUuid/:taskUuid', { listUuid: '@listUuid'}, {
      index: {method: 'GET', isArray: true},
      create: {method: 'POST'}
      show: {method: 'GET'}
      update: {method: 'PUT'}
      destroy: {method: 'DELETE'}
    }

