angular.module("testApp", [])
.directive "myCircularIndicator", ->

  link = (scope, element, attrs) ->
    attrs.expected = scope.expected = parseFloat(scope.expected or 0)
    attrs.actual = scope.actual = parseFloat(scope.actual or 0)
    attrs.margin = scope.margin = parseFloat(scope.margin or 0)

    svg = d3.select(element[0]).append("svg")

    makeArcTween = (arcFunction) ->
      (transition, newAngle) ->
        transition.attrTween "d", (d) ->
          interpolate = d3.interpolate(d.endAngle, newAngle)
          (t) ->
            d.endAngle = interpolate(t)
            arcFunction d

    scope.render = ->
      svg.selectAll("*").remove()
      width = d3.select(element[0]).node().offsetWidth - scope.margin
      r = width / 2
      center = "translate(" + r + "," + r + ")"

      makeArc = (inner, outer, class_, angle) ->
        arc = d3.svg.arc()
          .startAngle(0)
          .innerRadius(inner)
          .outerRadius(outer)
        arcTween = makeArcTween(arc)
        arcPath = svg.append("path")
          .datum endAngle: 0
          .attr "class", class_
          .attr "transform", center
          .attr "d", arc
        arcPath.transition()
          .duration(750)
          .call(arcTween, angle)
        arcPath

      makeText = (text, color, size, dx, dy) ->
        svg.append("text")
          .text(text)
          .style "font-size", size
          .style "fill", color
          .style "text-anchor", "middle"
          .style "font-family", "Helvetica Neue"
          .style "font-weight", "200"
          .attr "dx", dx
          .attr "dy", dy
          .attr "transform", center

      svg.append("circle")
        .style "fill", "#eee"
        .attr "r", r * 0.73
        .attr "transform", center

      makeArc r * 0.82, r * 0.87, scope.expectedArcClass, scope.expected * 2 * Math.PI
      makeArc r * 0.89, r * 1.00, scope.actualArcClass, scope.actual * 2 * Math.PI
      makeText scope.actual * 100, "#666", r * .54, r * -0.08, r * 0.07
      makeText "%", "#666", r * .27, r * 0.31, r * 0.05
      makeText "Progress", "#999", r * .22, 0, r * .28
      return

    window.onresize = ->
      scope.$apply()
      return

    scope.$watch (->
      angular.element(window)[0].innerWidth
    ), scope.render

    return

  restrict: "E"
  scope:
    expected: "@"
    actual: "@"
    expectedArcClass: "@"
    actualArcClass: "@"
    margin: "@"
  link: link
