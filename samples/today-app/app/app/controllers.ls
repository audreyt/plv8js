mod = {}


mod.ListController = <[$scope List Task $location $routeParams]> +++ ($scope, List, Task, $location, $routeParams) ->
  $scope._id = $routeParams.listUuid
  $scope.tasks = []
  # Defined before we call it
  $scope.redirectToNewList = ->
     List.create {}, (resource) -> $location.path '/list/' + resource._id , (response) -> console.log response

  if ($routeParams.listUuid == "")
     $scope.redirectToNewList!

  if $scope._id
    $scope.list = List.get {_id: $scope._id}, ((resource) ->
        unless resource
            $scope.redirectToNewList!
        $scope.tasks = resource.tasks || []
        console.log resource
        console.log 'OK'), (response) -> console.log response

  Task.index {},  ((resource) -> $scope.tasks = resource)

  $scope.updateList = (data) ->
    console.log 'Update'
    List.update {}, data, ((resource) -> console.log resource), (response) -> console.log response

  $scope.addTasks = (lines) ->
     tasks = lines / /[\r\n]+/
     for item in tasks
        console.log $scope._id
        Task.save {}, { _List: $scope._id, Description: item }, ((resource) -> $scope.tasks.push resource ), (response) -> console.log response

  $scope.updateTask = (index,data) ->
    console.log "Test"
    task = $scope.tasks[index]
    Task.update {_id: task._id }, data, ((resource) -> console.log resource), (response) -> console.log response
      # ajax success

  $scope.destroyTask = (index) ->
    console.log 'Destroy'
    task = $scope.tasks[index]
    Task.destroy {_id: task._id}, ((resource) ->
      # ajax success
      if not (index is -1)
        $scope.tasks.splice index, 1), (response) -> console.log response

  $scope.toggleComplete = (idx) ->
    task =  $scope.tasks[idx]
    console.log task + idx
    Task.update { _id: task._id } { Complete: task.Complete }


angular.module 'app.controllers' [] .controller mod
