LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy extends LOI.Adventure.Item
  keyName: -> 'pixelboy'
  displayName: -> "PixelBoy 2000"
  isActivatable: -> true
  activateVerbs: -> ["look at", "open"]
  deactivateVerbs: -> ["put away", "close"]

  constructor: (@adventure) ->
    super

    # This is the blaze component we're using to render the chrome.
    @itemComponent = new PAA.PixelBoy.Components.Item @

    # This is the OS running on the PixelBoy.
    @os = new PAA.PixelBoy.OS @

  renderComponent: (currentComponent) ->
    @itemComponent.renderComponent currentComponent

  onActivate: (finishedActivatingCallback) ->
    Tracker.autorun (computation) =>
      return unless @itemComponent.isRendered()
      computation.stop()

      # From here on you can use @itemComponent.$pixelboy()
      # TODO: Animate in the device. When it's fully in view call:

      # Wait for CSS animation to finish.
      Meteor.setTimeout =>
        finishedActivatingCallback()
      ,
        1000

  onDeactivate: (finishedDeactivatingCallback) ->
    # TODO: Animate out the device. When it's out of the view call:

    # Wait for CSS animation to finish.
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      1000

  update: (appTime) ->
    # Do your game loop update code here, if needed. # All apps' update routines will be called before all apps' draw
    # routines in case you need to organize based on that. But in general, update is the place where most processing
    # happens (usually AI, physics, etc in games) and draw is where things related to just how things get drawn. In
    # both, appTime.totalAppTime and appTime.elapsedAppTime can be used. Elapsed one lets you know how much time passed
    # from the last time update/draw was called (in seconds).

  visible: ->
    # This controls if the draw method needs to be called.
    not @deactivated()

  draw: (appTime) ->
    # Do your game loop rendering code here, if needed.

    # If you need to, you can pass the update/draw calls down into the component, for example:
    @itemComponent.draw appTime
