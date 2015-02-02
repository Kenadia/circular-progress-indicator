angular.module "testApp"
.directive "circularProgressIndicator", () ->

  ANIMATION_DURATION = 750
  INNER_ARC_INSIDE = 0.83
  INNER_ARC_OUTSIDE = 0.88
  INNER_CIRCLE_SIZE = 0.72
  OUTER_ARC_INSIDE = 0.90
  OUTER_ARC_OUTSIDE = 1.00
  STRING_PROGRESS = "Progress"
  TEXT_OFFSET_X_ACTUAL_PERCENT = 0.26
  TEXT_OFFSET_X_PERCENT_SYMBOL = 0.24
  TEXT_OFFSET_X_PROGRESS = 0.05
  TEXT_OFFSET_Y_ACTUAL_PERCENT = 0.01
  TEXT_OFFSET_Y_PERCENT_SYMBOL = 0.01
  TEXT_OFFSET_Y_PROGRESS = .26
  TEXT_SIZE_ACTUAL_PERCENT = .48
  TEXT_SIZE_PRECENT_SYMBOL = .27
  TEXT_SIZE_PROGRESS = .20
  WEAK_THRESHOLD = 0.75
  WEAKER_THRESHOLD = 0.5
  WINDOW_RESIZE_DEBOUNCE_DURATION = 250

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

    makeText = (text, class_, size, align, dx, dy) ->
      svg.append("text")
        .text(text)
        .style "font-size", size
        .style "text-anchor", align
        .attr "class", class_
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
      makeCircle r * INNER_CIRCLE_SIZE, scope.indicatorCenterClass
      innerArcFunction = makeArcFunction r * INNER_ARC_INSIDE,
        r * INNER_ARC_OUTSIDE
      outerArcFunction = makeArcFunction r * OUTER_ARC_INSIDE,
        r * OUTER_ARC_OUTSIDE
      innerArc = makeArc innerArcFunction, scope.expectedArcClass
      outerArc = makeArc outerArcFunction, scope.actualArcClass
      animateInner = makeArcAnimation innerArcFunction, innerArc
      animateOuter = makeArcAnimation outerArcFunction, outerArc
      makeText "", scope.textClass, r * TEXT_SIZE_ACTUAL_PERCENT, "end",
        r * TEXT_OFFSET_X_ACTUAL_PERCENT, r * TEXT_OFFSET_Y_ACTUAL_PERCENT
      makeText "%", scope.textClass, r * TEXT_SIZE_PRECENT_SYMBOL, "start",
        r * TEXT_OFFSET_X_PERCENT_SYMBOL, r * TEXT_OFFSET_Y_PERCENT_SYMBOL
      makeText STRING_PROGRESS, scope.textClass, r * TEXT_SIZE_PROGRESS, "middle",
        r * TEXT_OFFSET_X_PROGRESS, r * TEXT_OFFSET_Y_PROGRESS

      # Don't animate if arcs have been rendered previously
      # and animateOnResize is false
      if initialRender or scope.animateOnResize
        duration = ANIMATION_DURATION
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
      scope.updateValues ANIMATION_DURATION
    scope.$watch "actual", ->
      scope.updateValues ANIMATION_DURATION

    # Update bindings when window changes size to detect change in element width
    debouncedApply = _.debounce (->
      scope.$apply()
    ), WINDOW_RESIZE_DEBOUNCE_DURATION
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
    textClass: "@"
    animateOnResize: "=?"
  link: link
