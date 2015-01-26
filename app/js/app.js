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
      var radius = width / 2;
      var center = 'translate(' + width / 2 + ',' + width / 2  + ')';
      var innerArc = d3.svg.arc()
        .startAngle(0)
        .innerRadius(radius * 0.82)
        .outerRadius(radius * 0.87);
      var outerArc = d3.svg.arc()
        .startAngle(0)
        .innerRadius(radius * 0.89)
        .outerRadius(radius);
      var innerArcTween = makeArcTween(innerArc);
      var outerArcTween = makeArcTween(outerArc);
      var circle = svg.append('circle')
        .attr('r', radius * 0.73)
        .style('fill', '#eee')
        .attr('transform', center);
      svg.append('text')
        .text(scope.actual * 100)
        .style('text-anchor', 'middle')
        .style('font-family', 'Helvetica Neue')
        .style('font-weight', '200')
        .style('font-size', '32px')
        .style('fill', '#666')
        .attr('dx', -5)
        .attr('dy', 4)
        .attr('transform', center);
      svg.append('text')
        .text('%')
        .style('font-family', 'Helvetica Neue')
        .style('font-weight', '200')
        .style('font-size', '16px')
        .style('fill', '#666')
        .attr('dx', 12)
        .attr('dy', 3)
        .attr('transform', center);
      svg.append('text')
        .text('Progress')
        .style('text-anchor', 'middle')
        .style('font-family', 'Helvetica Neue')
        .style('font-weight', '200')
        .style('font-size', '13px')
        .style('fill', '#999')
        .attr('dy', 17)
        .attr('transform', center);
      var inner = svg.append('path')
        .datum({endAngle: 0})
        .style('fill', '#C7E596')
        .attr('transform', center)
        .attr('d', innerArc);
      var outer = svg.append('path')
        .datum({endAngle: 0})
        .style('fill', '#78C000')
        .attr('transform', center)
        .attr('d', outerArc);
      inner.transition()
        .duration(750)
        .call(innerArcTween, scope.expected * 2 * Math.PI);
      outer.transition()
        .duration(750)
        .call(outerArcTween, scope.actual * 2 * Math.PI);
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
