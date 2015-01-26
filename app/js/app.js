'use strict'

angular.module('testApp', [])
.directive('myCircularIndicator', function () {

  var link = function (scope, element, attrs) {
    var width = attrs.width = scope.width = parseInt(scope.width || 100);
    var height = attrs.height = scope.height = parseInt(scope.height || scope.width);
    attrs.expected = scope.expected = parseFloat(scope.expected || 0);
    attrs.actual = scope.actual = parseFloat(scope.actual || 0);
    var radius = Math.min(width, height) / 2.0
    var arc = d3.svg.arc()
                .innerRadius(radius * 0.9)
                .outerRadius(radius)
                .startAngle(0);
    var svg = d3.select(element[0]).append('svg')
                .attr('width', width)
                .attr('height', height)
              .append('g')
                .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');
    var outer = svg.append('path')
                   .datum({endAngle: 0})
                   .style('fill', '#8f6')
                   .attr('d', arc);
    var arcTween = function arcTween(transition, newAngle) {
      transition.attrTween('d', function (d) {
        var interpolate = d3.interpolate(d.endAngle, newAngle);
        return function (t) {
          d.endAngle = interpolate(t);
          return arc(d);
        };
      });
    };
    outer.transition()
        .duration(750)
        .call(arcTween, scope.actual * 2 * Math.PI);
  }

  return {
    restrict: 'E',
    scope: {
      width: '@',
      height: '@',
      expected: '@',
      actual: '@'
    },
    link: link
  };
});
