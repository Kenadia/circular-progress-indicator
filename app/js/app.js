'use strict'

angular.module('testApp', [])
.controller('Controller', ['$scope', function ($scope) {
  $scope.outer_data = {
    value: 'Value'
  };
}])
.directive('myCircularIndicator', function () {
  return {
    restrict: 'E',
    scope: {
      data: '='
    },
    templateUrl: 'templates/my-circular-indicator.html'
  };
});
