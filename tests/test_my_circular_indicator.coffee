describe "directive: my-circular-indicator", ->
  scope = undefined
  element = undefined

  beforeEach module "testApp"

  beforeEach inject ($rootScope, $compile) ->
    scope = $rootScope.$new()
    element = ['<my-circular-indicator expected="expected"'
      'actual="actual"></my-circular-indicator>'].join ""
    scope.expected = 0.1
    scope.actual = 0.2
    element = $compile(element)(scope)
    scope.$digest()

  describe "with the initial values", ->
    it "should do something", ->
      expect(scope.expected).toBe(0.1)
      expect(scope.actual).toBe(0.2)
