angular.module "testApp", []
.controller "Controller", ["$scope", ($scope) ->

  $scope.animateOnResize = true
  $scope.expected = 0.5
  $scope.actual = 0.73
  $scope.variableIndicatorSize = 100

  $(document).ready ->
    $(".js-expected-slider").slider(
        value: $scope.expected * 100
        stop: (event, ui) ->
          $scope.$apply ->
            $scope.expected = Math.round(ui.value) / 100.0
            return
      )
    $(".js-actual-slider").slider(
        value: $scope.actual * 100
        stop: (event, ui) ->
          $scope.$apply ->
            $scope.actual = Math.round(ui.value) / 100.0
            return
      )
    $(".js-size-slider").slider(
        value: $scope.variableIndicatorSize / 2
        stop: (event, ui) ->
          $scope.$apply ->
            $scope.variableIndicatorSize = 2 * ui.value
            $(".js-variable-indicator").width($scope.variableIndicatorSize)
            $(".js-variable-indicator").height($scope.variableIndicatorSize)
            return
      )
    return
]

