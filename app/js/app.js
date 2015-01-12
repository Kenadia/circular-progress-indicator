'use strict'

angular.module('testApp', [])
.controller('Controller', ['$scope', function ($scope)
{
  $scope.data = {
    value: 'value'
  };
}])
.directive('myCircularIndicator', function () {
  return {
    template: 'Data: {{data.value}}'
  };
});
