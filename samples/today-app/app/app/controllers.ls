mod = {}


mod.ListController = <[$scope List Task $location $routeParams $timeout]> +++ ($scope, List, Task, $location, $routeParams, $timeout) ->

  $scope <<< do

    listFinalized: ->
      now = new Date()
      # For now, lists last for about a minute
      #return (now - $scope.list.CreatedAt) > (60 * 60 * 18)
      return (now - $scope.list.CreatedAt) > (1000 * 60 * 60 * 18)
  #
    formatTime: (ms) ->
        now = new Date(ms)
        output = ''
        output += $scope.pad2 now.getUTCHours! + ":" if now.getUTCHours!
        output += $scope.pad2 now.getUTCMinutes! + ":"
        output += $scope.pad2 now.getUTCSeconds!
        return output

    pad2: (num) ->
        if num < 10
            "0"+num
        else
            num


    startClock: ->
      $timeout do
        function some-work
            latestUpdate = $scope.list.CreatedAt
            for {CompletedAt:c}:t in $scope.tasksComplete!
                if c > latestUpdate
                    latestUpdate = c
            now = new Date()
            $scope.clock = $scope.formatTime ((now - latestUpdate))
            $timeout some-work, 1000ms
        1000ms

    initialTasksCompletePercentage: ->
      100 * ( $scope.initialTasksComplete!length / $scope.initialTasks!length)

    initialTasks: ->
      $scope.tasks.filter -> !it.AddedLater

    initialTasksComplete: ->
      $scope.tasks.filter -> it.Complete and !it.AddedLater

    laterTasksComplete: ->
      $scope.tasks.filter -> it.Complete and it.AddedLater

    tasksIncomplete: ->
      $scope.tasks.filter -> ! it.Complete

    tasksComplete: ->
      $scope.tasks.filter -> it.Complete

    addTasks: (lines) ->
     isLater = !!$scope.tasks.length

     for item in lines / /[\r\n]+/
        Task.save {_List: $scope.list._id}, { _List: $scope._id, Description: item, AddedLater: isLater }, 
            ((resource) -> $scope.tasks.push resource ), 
            (response) -> console.log response

    updateTask: (task) ->
        if task.Complete and not task.CompletedAt
            task.CompletedAt = new Date
        else if !task.Complete and task.CompletedAt
            task.CompletedAt = null
        task.$update {}, ((resource) -> resource.CompletedAt = new Date(resource.CompletedAt) if resource.CompletedAt)

    destroyTask: (task) ->
      task.$delete!
      $scope.tasks .=filter -> it isnt task

    redirectToNewList: ->
       List.create {PreviousList: $scope._id}, (resource) -> (
           if $scope.list
               $scope.list.NextList = resource._id
               $scope.list.$update!
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
        $scope.startClock!

        ), (response) -> console.log response

  Task.index {_List: $scope._id},  ((resource) ->
      for {CompletedAt}:t in resource
            t.CompletedAt = new Date CompletedAt if CompletedAt
      $scope.tasks = resource
      ), (response) -> console.log response

angular.module 'app.controllers' [] .controller mod
