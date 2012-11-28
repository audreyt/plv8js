mod = {}


mod.ListController = <[$scope List Task $location $routeParams]> +++ ($scope, List, Task, $location, $routeParams) ->
  # Defined before we call it
  $scope.redirectToNewList = ->
   List.create {}, (resource) -> $location.path '/list/' + resource._id , (response) -> console.log response

  $scope._id = $routeParams.listUuid

  if $scope._id
    $scope.list = List.get {_id: $scope._id}, ((resource) ->
          console.log 'OK'), (response) -> console.log response

  if $scope.list == undefined
       $scope.redirectToNewList!

  $scope.tasks = $scope.list.tasks


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
