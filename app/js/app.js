'use strict'

angular.module('testApp', [])
.directive('myCircularIndicator', function () {

  var link = function (scope, element, attrs) {
    attrs.expected = scope.expected = parseFloat(scope.expected || 0);
    attrs.actual = scope.actual = parseFloat(scope.actual || 0);
    attrs.margin = scope.margin = parseFloat(scope.margin || 0);

    var svg = d3.select(element[0]).append('svg');

    var makeArcTween = function makeArcTween(arcFunction) {
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
      var r = width / 2;
      var center = 'translate(' + width / 2 + ',' + width / 2  + ')';

      var makeArc = function makeArc(inner, outer, color, angle) {
        var arc = d3.svg.arc()
          .startAngle(0)
          .innerRadius(inner)
          .outerRadius(outer)
        var arcTween = makeArcTween(arc);
        var arcPath = svg.append('path')
          .datum({endAngle: 0})
          .style('fill', color)
          .attr('transform', center)
          .attr('d', arc);
        arcPath.transition()
          .duration(750)
          .call(arcTween, angle);
        return arcPath;
      }

      var makeText = function makeText(text, color, size, dx, dy) {
        return svg.append('text')
          .text(text)
          .style('font-size', size)
          .style('fill', color)
          .style('text-anchor', 'middle')
          .style('font-family', 'Helvetica Neue')
          .style('font-weight', '200')
          .attr('dx', dx)
          .attr('dy', dy)
          .attr('transform', center)
      }

      svg.append('circle')
        .attr('r', r * 0.73)
        .style('fill', '#eee')
        .attr('transform', center);

      makeArc(r * 0.82, r * 0.87, '#C7E596', scope.expected * 2 * Math.PI);
      makeArc(r * 0.89, r * 1.00, '#78C000', scope.actual * 2 * Math.PI);

      makeText(scope.actual * 100, '#666', r * .54, r * -0.08, r * 0.07);
      makeText('%', '#666', r * .27, r * 0.31, r * 0.05);
      makeText('Progress', '#999', r * .22, 0, r * .28);

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
