angular.module "testApp"
.directive "myCircularIndicator", () ->

  WEAK_THRESHOLD = 0.75
  WEAKER_THRESHOLD = 0.5

  link = (scope, element, attrs) ->
    attrs.expected = scope.expected = parseFloat(scope.expected or 0)
    attrs.actual = scope.actual = parseFloat(scope.actual or 0)
    if typeof scope.animateOnResize == "undefined"
      scope.animateOnResize = true

    svg = d3.select(element[0]).append("svg")
      .style("width", "100%")
      .style("height", "100%")
    initialRender = true # True until the svg has rendered once

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
        .endAngle(angle)
        .innerRadius(inner)
        .outerRadius(outer)
      svg.append("path")
        .attr "class", class_
        .attr "transform", scope.center
        .attr "d", arc

    makeAnimatedArc = (inner, outer, class_, angle) ->
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

    makeText = (text, color, size, align, dx, dy) ->
      svg.append("text")
        .text(text)
        .style "font-size", size
        .style "fill", color
        .style "text-anchor", align
        .attr "dx", dx
        .attr "dy", dy
        .attr "transform", scope.center

    sanitizePercentage = (value) ->
      (Math.min 1, Math.max 0, parseFloat value) or 0

    scope.render = ->
      if initialRender or scope.animateOnResize
        makeArcFn = makeAnimatedArc
      else
        makeArcFn = makeArc
      svg.selectAll("*").remove()
      r = scope.width / 2.0 # Radius
      scope.center = "translate(" + r + "," + scope.height / 2.0 + ")"
      expected = sanitizePercentage(scope.expected)
      actual = sanitizePercentage(scope.actual)
      actualClasses = [scope.actualArcClass]
      if actual / expected < WEAKER_THRESHOLD
        actualClasses.push "weaker"
      else if actual / expected < WEAK_THRESHOLD
        actualClasses.push "weak"
      makeCircle r * 0.73, scope.indicatorCenterClass
      makeArcFn r * 0.82, r * 0.87, scope.expectedArcClass, expected * 2 * Math.PI
      makeArcFn r * 0.89, r * 1.00, (actualClasses.join " "), actual * 2 * Math.PI
      makeText actual * 100, "#666", r * .54, "end", r * 0.3, r * 0.07
      makeText "%", "#666", r * .27, "start", r * 0.3, r * 0.05
      makeText "Progress", "#999", r * .22, "middle", 0, r * .28
      initialRender = false
      return

    # Render when the element width changes
    scope.$watch (getElementWidth = ->
        scope.height = element[0].offsetHeight
        scope.width = element[0].offsetWidth
      ), scope.render

    scope.$watch "expected", scope.render
    scope.$watch "actual", scope.render

    # Update bindings when window changes size to detect change in element width
    debouncedApply = _.debounce (->
        scope.$apply()
      ), 250
    angular.element(window).bind "resize", debouncedApply

    scope.$on "$destroy", cleanup = ->
      angular.element(window).unbind "resize", debouncedApply

    return

  restrict: "E"
  scope:
    expected: "="
    actual: "="
    indicatorCenterClass: "@"
    expectedArcClass: "@"
    actualArcClass: "@"
    animateOnResize: "=?"
  link: link
