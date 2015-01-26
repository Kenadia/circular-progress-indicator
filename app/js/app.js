'use strict'

angular.module('testApp', [])
.directive('myCircularIndicator', function () {

  var link = function (scope, element, attrs) {
    attrs.expected = scope.expected = parseFloat(scope.expected || 0);
    attrs.actual = scope.actual = parseFloat(scope.actual || 0);
    attrs.margin = scope.margin = parseFloat(scope.margin || 0);

    var svg = d3.select(element[0]).append('svg');

    var makeTween = function makeTween(arcFunction) {
      return function (transition, newAngle) {
        transition.attrTween('d', function (d) {
          var interpolate = d3.interpolate(d.endAngle, newAngle);
          return function (t) {
            d.endAngle = interpolate(t);
            return arcFunction(d);
          };
        });
      };
    }

    scope.render = function () {
      svg.selectAll('*').remove();
      var width = d3.select(element[0]).node().offsetWidth - scope.margin;
      var radius = width / 2;
      var center = 'translate(' + width / 2 + ',' + width / 2  + ')';
      var arc = d3.svg.arc()
        .startAngle(0);
      var arcTween = makeTween(arc);
      var circle = svg.append('circle')
        .attr('r', radius * 0.75)
        .style('fill', '#eee')
        .attr('transform', center);
      var inner = svg.append('path')
        .datum({
          endAngle: 0,
          innerRadius: radius * 0.82,
          outerRadius: radius * 0.86
        })
        .style('fill', '#8f6')
        .attr('transform', center)
        .attr('d', arc);
      var outer = svg.append('path')
        .datum({
          endAngle: 0,
          innerRadius: radius * 0.9,
          outerRadius: radius
        })
        .style('fill', '#4d5')
        .attr('transform', center)
        .attr('d', arc);
      outer.transition()
        .duration(750)
        .call(arcTween, scope.actual * 2 * Math.PI);
      inner.transition()
        .duration(750)
        .call(arcTween, scope.expected * 2 * Math.PI);
    };

    window.onresize = function () {
      scope.$apply();
    };

    scope.$watch(function () {
      return angular.element(window)[0].innerWidth;
    }, scope.render);
  }

  return {
    restrict: 'E',
    scope: {
      expected: '@',
      actual: '@',
      margin: '@'
    },
    link: link
  };
});
