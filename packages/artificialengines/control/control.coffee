class Artificial.Control
  if Meteor.isClient
    @hasTouch = window.ontouchstart?

  @initialize: ->
    @Keyboard.initialize()
    @Pointer.initialize()
