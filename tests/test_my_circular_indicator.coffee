describe "directive: my-circular-indicator", ->

  scope = undefined
  element = undefined

  beforeEach module "testApp"

  beforeEach inject ($rootScope, $compile) ->
    scope = $rootScope.$new()
    element = ['<my-circular-indicator expected="expected"'
      'indicator-center-class="indicator-center"'
      'expected-arc-class="inner-arc" actual-arc-class="outer-arc"'
      'actual="actual"></my-circular-indicator>'].join ""
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
