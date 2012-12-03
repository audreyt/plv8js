mod = {}


mod.ListController = <[$scope List $location $routeParams $timeout]> +++ ($scope, List, $location, $routeParams, $timeout) ->

  $scope <<< do
    processList: (list) ->
        list.CreatedAt = new Date(list.CreatedAt)
        if list.NextList
            $scope.nextList = list.get { _id: list.NextList }, (nextList) -> (
               nextList.CreatedAt = new Date(nextList.CreatedAt))
        if list.PreviousList
            $scope.previousList = List.get { _id: list.PreviousList }, (previousList) -> (
               previousList.CreatedAt = new Date(previousList.CreatedAt))
        for task in list.tasks
            task.CreatedAt = new Date(task.CreatedAt) if task.CreatedAt
            task.CompletedAt = new Date(task.CompletedAt) if task.CompletedAt

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
        output += $scope.pad2(now.getUTCMinutes!) + ":"
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
      Math.max  1, 100 * ( $scope.initialTasksComplete!length / $scope.initialTasks!length)

    initialTasks: ->
      $scope.list.tasks.filter -> !it.AddedLater

    initialTasksComplete: ->
      $scope.list.tasks.filter -> it.Complete and !it.AddedLater

    laterTasksComplete: ->
      $scope.list.tasks.filter -> it.Complete and it.AddedLater

    tasksIncomplete: ->
      $scope.list.tasks.filter -> not it.Complete

    tasksComplete: ->
      $scope.list.tasks.filter -> it.Complete

    addTasks: (lines) ->
     isLater = !!$scope.list.tasks.length

     for item in lines / /[\r\n]+/
        $scope.list.tasks.push { Description: item, AddedLater: isLater }
     $scope.list.$update {}, ((resource) -> $scope.processList(resource))


    updateTask: (task) ->
        if task.Complete and not task.CompletedAt
            task.CompletedAt = new Date
        else if !task.Complete and task.CompletedAt
            task.CompletedAt = null
        $scope.list.$update {}, ((resource) -> $scope.processList(resource))

    destroyTask: (task) ->
      $scope.list.tasks .=filter -> it isnt task
      $scope.list.$update {}, ((resource) -> $scope.processList(resource))

    redirectToNewList: ->
       List.save {PreviousList: $scope._id}, (resource) -> (
           if $scope.list
               $scope.list.NextList = resource._id
               $scope.list.$update {}, ((resource) -> $scope.processList(resource))
           $location.path '/list/' + resource._id ),
           (response) -> console.log response

  $scope._id = $routeParams.listUuid
  # Defined before we call it

  if ($routeParams.listUuid == "")
     $scope.redirectToNewList!

  if $scope._id
    $scope.list = List.get {_id: $scope._id}, ((resource) ->
        unless resource
            $scope.redirectToNewList!
        $scope.processList(resource)
        $scope.startClock!

        ), (response) -> console.log response

#  Task.index {_List: $scope._id},  ((resource) ->
#      for {CompletedAt}:t in resource
#            t.CompletedAt = new Date CompletedAt if CompletedAt
#      $scope.list.tasks = resource
#      ), (response) -> console.log response
#
angular.module 'app.controllers' [] .controller mod
