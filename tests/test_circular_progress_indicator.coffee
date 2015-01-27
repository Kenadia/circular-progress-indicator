describe "directive: circular-progress-indicator", ->

  scope = undefined
  element = undefined

  beforeEach module "testApp"

  beforeEach inject ($rootScope, $compile) ->
    scope = $rootScope.$new()
    element = ['<circular-progress-indicator expected="expected"'
      'indicator-center-class="indicator-center"'
      'expected-arc-class="inner-arc" actual-arc-class="outer-arc"'
      'actual="actual"></circular-progress-indicator>'].join ""
    scope.expected = 0.4
    scope.actual = 0.65
    element = $compile(element)(scope)
    scope.$digest()

  describe "with the initial values", ->

    it "should contain svg elements with the correct classes", ->
      expect(element.find("circle").attr("class")).toBe("indicator-center")
      expect(element[0].querySelector(".inner-arc")).not.toBe(null)
      expect(element[0].querySelector(".outer-arc")).not.toBe(null)

    it "should contain text elements with the correct content", ->
      expect(element.find("text")[0].innerHTML).toBe(String(scope.actual * 100))
      expect(element.find("text")[1].innerHTML).toBe("%")
      expect(element.find("text")[2].innerHTML).toBe("Progress")

  describe "with other values", ->

    it "should update if given a reasonable value", ->
      scope.actual = 0.73
      scope.$digest()
      expect(element.find("text")[0].innerHTML).toBe("73")

    it "should show zero if given a non-number", ->
      scope.actual = "a string"
      scope.$digest()
      expect(element.find("text")[0].innerHTML).toBe("0")
      scope.actual = NaN
      scope.$digest()
      expect(element.find("text")[0].innerHTML).toBe("0")
      scope.actual = undefined
      scope.$digest()
      expect(element.find("text")[0].innerHTML).toBe("0")

    it "should limit numbers to the range 0–1", ->
      scope.actual = -1
      scope.$digest()
      expect(element.find("text")[0].innerHTML).toBe("0")
      scope.actual = -Infinity
      scope.$digest()
      expect(element.find("text")[0].innerHTML).toBe("0")
      scope.actual = 1.1
      scope.$digest()
      expect(element.find("text")[0].innerHTML).toBe("100")
      scope.actual = Infinity
      scope.$digest()
      expect(element.find("text")[0].innerHTML).toBe("100")

  describe "when actual percentage is trailing expected percentage", ->

    it "should not add any classes if actual is at least 75% expected", ->
      scope.expected = 0.5
      scope.actual = 0.375
      scope.$digest()
      expect(element[0].querySelector(".outer-arc").classList.length).toBe(1)

    it "should add the 'weak' class if actual is <75% but at least 50% expected", ->
      scope.expected = 0.5
      scope.actual = 0.374
      scope.$digest()
      expect(element[0].querySelector(".outer-arc").classList[1])
        .toBe("outer-arc-weak")
      scope.actual = 0.25
      scope.$digest()
      expect(element[0].querySelector(".outer-arc").classList[1])
        .toBe("outer-arc-weak")

    it "should add the 'weaker' class if actual is below 50% expected", ->
      scope.expected = 0.5
      scope.actual = 0.245
      scope.$digest()
      expect(element[0].querySelector(".outer-arc").classList[1])
        .toBe("outer-arc-weaker")
      scope.actual = 0
      scope.$digest()
      expect(element[0].querySelector(".outer-arc").classList[1])
        .toBe("outer-arc-weaker")
