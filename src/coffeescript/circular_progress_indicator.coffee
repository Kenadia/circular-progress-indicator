angular.module "testApp"
.directive "circularProgressIndicator", () ->

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
    outerArc = undefined
    animateInner = undefined
    animateOuter = undefined

    makeCircle = (radius, class_) ->
      svg.append("circle")
        .attr "class", class_
        .attr "r", radius
        .attr "transform", scope.center

    makeArcFunction = (inner, outer) ->
      d3.svg.arc()
        .startAngle(0)
        .innerRadius(inner)
        .outerRadius(outer)

    makeArc = (arc_fn, class_) ->
      svg.append("path")
        .datum endAngle: 0
        .attr "class", class_
        .attr "transform", scope.center
        .attr "d", arc_fn

    makeArcAnimation = (arc_fn, arcPath) ->
      arcTween = (transition, newAngle) ->
        transition.attrTween "d", (d) ->
          interpolate = d3.interpolate(d.endAngle, newAngle)
          (t) ->
            d.endAngle = interpolate(t)
            arc_fn d
      (value, duration) ->
        arcPath.transition()
          .duration(duration)
          .call(arcTween, value * 2 * Math.PI)

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
      svg.selectAll("*").remove()
      r = (Math.min scope.width, scope.height) / 2.0 # Radius
      scope.center = "translate(" + scope.width / 2.0 + "," +
        scope.height / 2.0 + ")"

      # Make SVG elements
      makeCircle r * 0.72, scope.indicatorCenterClass
      innerArcFunction = makeArcFunction r * 0.83, r * 0.88
      outerArcFunction = makeArcFunction r * 0.90, r * 1.00
      innerArc = makeArc innerArcFunction, scope.expectedArcClass
      outerArc = makeArc outerArcFunction, scope.actualArcClass
      animateInner = makeArcAnimation innerArcFunction, innerArc
      animateOuter = makeArcAnimation outerArcFunction, outerArc
      makeText "", "#666", r * .48, "end", r * 0.26, r * 0.01
      makeText "%", "#666", r * .27, "start", r * 0.24, r * 0.01
      makeText "Progress", "#999", r * .20, "middle", r * 0.05, r * .26

      # Don't animate if arcs have been rendered previously
      # and animateOnResize is false
      if initialRender or scope.animateOnResize
        duration = 750
      else
        duration = 0
      initialRender = false
      scope.updateValues(duration)

      return

    scope.updateValues = (duration) ->
      if initialRender
        return
      expected = sanitizePercentage(scope.expected)
      actual = sanitizePercentage(scope.actual)

      # Update text
      textNode = element.find("text")[0]
      textNode.innerHTML = String(Math.round(actual * 100))

      # Determine classes for styling the outer arc
      outerArcClasses = [scope.actualArcClass]
      if actual / expected < WEAKER_THRESHOLD
        outerArcClasses.push scope.actualArcClass + "-weaker"
      else if actual / expected < WEAK_THRESHOLD
        outerArcClasses.push scope.actualArcClass + "-weak"
      outerArcNode = outerArc[0][0]
      outerArcNode.className.baseVal = outerArcClasses.join " "

      animateInner expected, duration
      animateOuter actual, duration

    # Re-render when the width of the element changes
    scope.$watch (getElementSize = ->
      scope.height = element[0].offsetHeight
      return scope.width = element[0].offsetWidth
    ), scope.render

    scope.$watch "expected", ->
      scope.updateValues 750
    scope.$watch "actual", ->
      scope.updateValues 750

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
