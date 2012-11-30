mod = {}


mod.ListController = <[$scope List Task $location $routeParams]> +++ ($scope, List, Task, $location, $routeParams) ->

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

    addTasks: (lines) ->

     isLater = !!$scope.tasks.length

     for item in lines / /[\r\n]+/
        Task.save {_List: $scope.list._id}, { _List: $scope._id, Description: item, AddedLater: isLater }, 
            ((resource) -> $scope.tasks.push resource ), 
            (response) -> console.log response

    destroyTask: (task) ->
      task.$delete!
      $scope.tasks .=filter -> it isnt task

    toggleComplete: (task) ->
      task.$update!

    redirectToNewList: ->
       List.create {PreviousList: $scope.list._id}, (resource) -> (
            if $scope.list._id
                $scope.list.NextList = resource._id
                $scope.list.$update
            $location.path '/list/' + resource._id ),
            (response) -> console.log response

  $scope._id = $routeParams.listUuid
  $scope.tasks = []
  # Defined before we call it

  if ($routeParams.listUuid == "")
     $scope.redirectToNewList!

  if $scope._id
    $scope.list = List.get {_id: $scope._id}, ((resource) ->
        unless resource
            $scope.redirectToNewList!
        $scope.tasks = resource.tasks || []
        resource.CreatedAt = new Date(resource.CreatedAt)
        if resource.NextList
            $scope.nextList = List.get { _id: resource.NextList }, (nextResource) -> (
               nextResource.CreatedAt = new Date(nextResource.CreatedAt))
        if resource.PreviousList
            $scope.previousList = List.get { _id: resource.PreviousList }, (previousResource) -> (
               previousResource.CreatedAt = new Date(previousResource.CreatedAt))
        ), (response) -> console.log response

  Task.index {_List: $scope._id},  ((resource) -> $scope.tasks = resource), (response) -> console.log response

angular.module 'app.controllers' [] .controller mod
