PAA = PixelArtAcademy

class PAA.PixelBoy extends PAA.Adventure.Item
  keyName: -> 'pixelboy'
  displayName: -> "PixelBoy 2000"
  isActivatable: -> true
  activateVerbs: -> ["look at", "open"]
  deactivateVerbs: -> ["put away", "close"]

  constructor: ->
    super

    # This is the blaze component we're using to render the chrome.
    @itemComponent = new PAA.PixelBoy.Components.Item @

  renderComponent: (currentComponent) ->
    @itemComponent.renderComponent currentComponent

  onActivate: (finishedActivatingCallback) ->
    #@itemComponent.$pixelboy().append("THIS WAS ADDED ON ACTIVATE")

    # TODO: Animate in the device. When it's fully in view call:
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # TODO: Animate out the device. When it's out of the view call:
    finishedDeactivatingCallback()

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

    # Demo (quick and ugly):
    #@itemComponent.$pixelboy().css
    #  background: "rgb(#{Math.floor Math.random() * 10 + 100},#{Math.floor Math.random() * 10 + 100},#{Math.floor Math.random() * 50 + 100})"
    #  left: "#{50 + Math.sin appTime.totalAppTime * 10}%"

    # If you need to, you can pass the update/draw calls down into the component, for example:
    @itemComponent.draw appTime
