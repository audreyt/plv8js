mod = {}


mod.ListController = <[$scope List Task $location $routeParams]> +++ ($scope, List, Task, $location, $routeParams) ->
  $scope._id = $routeParams.listUuid
  console.log "ID is: " +$scope._id
  for k, v of $routeParams
    console.log "#k #v"
  console.log $routeParams.listUuid

  $scope.redirectToNewList = ->
   List.create {}, (resource) -> $location.path '/list/' + resource._id , (response) -> console.log response

  if $scope._id
    $scope.list = List.get {_id: $scope._id}, ((resource) ->
          console.log "ID IS " + resource._id
          console.log 'OK'), (response) ->
              console.log "did not fetch ok!"
              console.log response
              $scope.redirectToNewList!
  else
    $scope.redirectToNewList!

  $scope.tasks = List.tasks

  $scope.createList = (data) ->
    List.save {}, data, ((resource) ->
      console.log resource
      ),
      ( (response) ->
        $scope.listUuid = 'xxx'# XXX how do I get that back
        console.log response
      )

  $scope.updateList = (data) ->
    console.log 'Update'
    List.update {}, data, ((resource) -> console.log resource), (response) -> console.log response

  $scope.addTasks = (lines) ->
     tasks = lines / /[\r\n]+/
     for item in tasks
        console.log $scope._id
        Task.save {}, { _List: $scope._id, Description: item }, ((resource) -> console.log resource), (response) -> console.log response

  $scope.updateTask = (index) ->
    task = $scope.tasks[index]
    task.update {
    }, ((resource) -> console.log resource), (response) -> console.log response
      # ajax success

  $scope.deleteTask = (index) ->
    console.log 'Destroy'
    task = $scope.tasks[index]
    task.destroy {}, ((resource) ->
      # ajax success
      if not (index is -1)
        $scope.tasks.splice index, 1), (response) -> console.log response


angular.module 'app.controllers' [] .controller mod
