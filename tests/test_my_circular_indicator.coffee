describe "directive: my-circular-indicator", ->
  scope = undefined
  element = undefined

  beforeEach module "testApp"

  beforeEach inject ($rootScope, $compile) ->
    scope = $rootScope.$new()

  describe "with the initial values", ->
    it "should do something", ->
      expect(1).toBe(1)
