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

  Task.index {_List: $scope._id},  ((resource) -> $scope.tasks = resource), (response) -> console.log response

  $scope.updateList = (data) ->
    console.log 'Update'
    List.update {}, data, ((resource) -> console.log resource), (response) -> console.log response

  $scope.addTasks = (lines) ->

     if $scope.tasks.length 
         isLater = true 
     else 
         isLater=false

     tasks = lines / /[\r\n]+/
     for item in tasks
        console.log $scope._id
        Task.save {_List: $scope.list._id}, { _List: $scope._id, Description: item, AddedLater: isLater }, ((resource) -> $scope.tasks.push resource ), (response) -> console.log response

  $scope.updateTask = (task,data) ->
    console.log "Test"
    Task.update {_id: task._id, _List: $scope.list._id }, data, ((resource) -> console.log resource), (response) -> console.log response
      # ajax success

  $scope.destroyTask = (task) ->
    console.log 'Destroy'
    Task.destroy {_id: task._id, _List: $scope.list._id}, ((resource) -> $scope.tasks .=filter -> it isnt task)

  $scope.toggleComplete = (task) ->
    Task.update { _id: task._id, _List: $scope.list._id } { Complete: task.Complete }


angular.module 'app.controllers' [] .controller mod
