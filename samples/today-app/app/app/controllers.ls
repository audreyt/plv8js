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

  $scope <<< do
    initialTasksCompletePercentage: ->
      100 * ( $scope.initialTasksComplete!length / $scope.initialTasks!length)

    initialTasks: ->
      $scope.tasks.filter -> !it.AddedLater

    initialTasksComplete: ->
      $scope.tasks.filter -> it.Complete and !it.AddedLater

    laterTasksComplete: ->
      $scope.tasks.filter -> it.Complete and it.AddedLater

    tTasksComplete: ->
      $scope.tasks.filter -> it.Complete

    updateList: (data) ->
      console.log 'Update'
      List.update {}, data, ((resource) -> console.log resource), (response) -> console.log response

    addTasks: (lines) ->

     isLater = !!$scope.tasks.length

     for item in lines / /[\r\n]+/
        console.log $scope._id
        Task.save {_List: $scope.list._id}, { _List: $scope._id, Description: item, AddedLater: isLater }, ((resource) -> $scope.tasks.push resource ), (response) -> console.log response

    updateTask: (task,data) ->
      console.log "Test"
      Task.update {_id: task._id, _List: $scope.list._id }, data, ((resource) -> console.log resource), (response) -> console.log response
      # ajax success

    destroyTask: (task) ->
      console.log 'Destroy'
      Task.destroy {_id: task._id, _List: $scope.list._id}, ((resource) -> $scope.tasks .=filter -> it isnt task)

    toggleComplete: (task) ->
      Task.update { _id: task._id, _List: $scope.list._id } { Complete: task.Complete }


angular.module 'app.controllers' [] .controller mod
