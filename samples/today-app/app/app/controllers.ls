mod = {}


mod.ListController = <[$scope List Task $routeParams]> +++ ($scope, List, Task, $routeParams) ->
  $scope.listUuid = $routeParams.listUuid
  $scope.list = List.get {}, ((resource) -> console.log 'OK'), (response) ->
  $scope.tasks = Task.index {}

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

  $scope.addTasks = ->
    # split the data by newline
      # create one task each
        Task.save { listUuid: $scope.listUuid}, taskData, ((resource) -> console.log resource), (response) -> console.log response

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
