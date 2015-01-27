angular.module "testApp", []
.directive "myCircularIndicator", () ->

  link = (scope, element, attrs) ->
    attrs.expected = scope.expected = parseFloat(scope.expected or 0)
    attrs.actual = scope.actual = parseFloat(scope.actual or 0)

    svg = d3.select(element[0]).append("svg")
      .style("width", scope.width)
      .style("height", scope.height)

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
        .attr "transform", scope.center

    makeArc = (inner, outer, class_, angle) ->
      arc = d3.svg.arc()
        .startAngle(0)
        .innerRadius(inner)
        .outerRadius(outer)
      arcTween = makeArcTween(arc)
      arcPath = svg.append("path")
        .datum endAngle: 0
        .attr "class", class_
        .attr "transform", scope.center
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
        .attr "transform", scope.center

    scope.render = ->
      svg.selectAll("*").remove()
      r = scope.width / 2.0 # Radius
      scope.center = "translate(" + r + "," + scope.height / 2.0 + ")"
      makeCircle r * 0.73, scope.indicatorCenterClass
      makeArc r * 0.82, r * 0.87, scope.expectedArcClass, scope.expected * 2 * Math.PI
      makeArc r * 0.89, r * 1.00, scope.actualArcClass, scope.actual * 2 * Math.PI
      makeText scope.actual * 100, "#666", r * .54, r * -0.09, r * 0.07
      makeText "%", "#666", r * .27, r * 0.31, r * 0.05
      makeText "Progress", "#999", r * .22, 0, r * .28
      return

    # Render when the element width changes
    scope.$watch (getElementWidth = ->
        scope.height = element[0].offsetHeight
        scope.width = element[0].offsetWidth
      ), scope.render

    # Update bindings when window changes size to detect change in element width
    debouncedApply = _.debounce (->
        scope.$apply()
      ), 300
    angular.element(window).bind "resize", debouncedApply

    scope.$on "$destroy", cleanup = ->
      angular.element(window).unbind "resize", debouncedApply

    return

  restrict: "E"
  scope:
    expected: "@"
    actual: "@"
    indicatorCenterClass: "@"
    expectedArcClass: "@"
    actualArcClass: "@"
  link: link
