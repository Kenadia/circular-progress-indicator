'use strict'

angular.module('testApp', [])
.controller('Controller', ['$scope', function ($scope) {
  $scope.outer_data = {
    value: 'Value'
  };
}])
.directive('myCircularIndicator', function () {

  var link = function (scope, element, attrs) {
    attrs.expected = scope.expected = parseFloat(scope.expected || 0);
    attrs.actual = scope.actual = parseFloat(scope.actual || 0);
  }

  return {
    restrict: 'E',
    scope: {
      expected: '@',
      actual: '@'
    },
    link: link,
    templateUrl: 'templates/my-circular-indicator.html'
  };
});
