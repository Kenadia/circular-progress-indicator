'use strict'

angular.module('testApp', [])
.controller('Controller', ['$scope', function ($scope)
{
  $scope.data = {
    value: 'Value'
  };
}])
.directive('myCircularIndicator', function () {
  return {
    template: 'Test 2: {{data.value}}'
  };
});
