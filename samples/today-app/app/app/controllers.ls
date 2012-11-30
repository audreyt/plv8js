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
        resource.CreatedAt = new Date(resource.CreatedAt)
        ), (response) -> console.log response

  Task.index {_List: $scope._id},  ((resource) -> $scope.tasks = resource), (response) -> console.log response

  $scope <<< do

    listFinalized: ->
      start = new Date($scope.list.CreatedAt)
      now = new Date()
      # For now, lists last for about a minute
      return (now - start) > (60 * 60 * 18)
  # return !! (now - start) > (1000 * 60 * 60 * 18)


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
      List.update {_id: $scope._id }, data, ((resource) -> console.log resource), (response) -> console.log response

    addTasks: (lines) ->

     isLater = !!$scope.tasks.length

     for item in lines / /[\r\n]+/
        Task.save {_List: $scope.list._id}, { _List: $scope._id, Description: item, AddedLater: isLater }, 
            ((resource) -> $scope.tasks.push resource ), 
            (response) -> console.log response

    updateTask: (task,data) ->
      Task.update {_id: task._id, _List: $scope.list._id }, data, ((resource) -> console.log resource), (response) -> console.log response
      # ajax success

    destroyTask: (task) ->
      console.log 'Destroy'
      Task.destroy {_id: task._id, _List: $scope.list._id}, ((resource) -> $scope.tasks .=filter -> it isnt task)

    toggleComplete: (task) ->
      Task.update { _id: task._id, _List: $scope.list._id } { Complete: task.Complete }


angular.module 'app.controllers' [] .controller mod
