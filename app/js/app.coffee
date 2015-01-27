angular.module("testApp", [])
.directive "myCircularIndicator", ->

  link = (scope, element, attrs) ->
    attrs.expected = scope.expected = parseFloat(scope.expected or 0)
    attrs.actual = scope.actual = parseFloat(scope.actual or 0)
    
    width = element[0].offsetWidth
    r = width / 2.0 # Radius
    center = "translate(" + r + "," + r + ")"
    svg = d3.select(element[0]).append("svg")
      .style('width', width)

    makeArcTween = (arcFunction) ->
      (transition, newAngle) ->
        transition.attrTween "d", (d) ->
          interpolate = d3.interpolate(d.endAngle, newAngle)
          (t) ->
            d.endAngle = interpolate(t)
            arcFunction d

    makeCircle = (radius, class_) ->
      svg.append("circle")
        .attr "class", class_
        .attr "r", radius
        .attr "transform", center

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
        .attr "dx", dx
        .attr "dy", dy
        .attr "transform", center

    scope.render = ->
      svg.selectAll("*").remove()
      makeCircle r * 0.73, scope.indicatorCenterClass
      makeArc r * 0.82, r * 0.87, scope.expectedArcClass, scope.expected * 2 * Math.PI
      makeArc r * 0.89, r * 1.00, scope.actualArcClass, scope.actual * 2 * Math.PI
      makeText scope.actual * 100, "#666", r * .54, r * -0.09, r * 0.07
      makeText "%", "#666", r * .27, r * 0.31, r * 0.05
      makeText "Progress", "#999", r * .22, 0, r * .28
      return

    scope.render()

    return

  restrict: "E"
  scope:
    expected: "@"
    actual: "@"
    indicatorCenterClass: "@"
    expectedArcClass: "@"
    actualArcClass: "@"
  link: link
