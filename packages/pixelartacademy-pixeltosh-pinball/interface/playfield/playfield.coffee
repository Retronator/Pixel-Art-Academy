LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Playfield extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Playfield'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram Pinball

  onRendered: ->
    super arguments...
    
    @$('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield').append @pinball.rendererManager().renderer.domElement

  events: ->
    super(arguments...).concat
      'mousedown': @onMouseDown
      'mousemove': @onMouseMove
      'mouseleave .pixelartacademy-pixeltosh-programs-pinball-interface-playfield': @onMouseLeavePlayfield
      'wheel': @onMouseWheel
      'contextmenu': @onContextMenu

  onMouseDown: (event) ->
    # Prevent browser select/dragging behavior.
    event.preventDefault()

    @pinball.cameraManager().startRotateCamera event.coordinates

  onMouseMove: (event) ->
    @pinball.mouse().onMouseMove event

  onMouseLeavePlayfield: (event) ->
    @pinball.mouse().onMouseLeave event

  onMouseWheel: (event) ->
    @pinball.cameraManager().changeDistanceByFactor 1.005 ** event.originalEvent.deltaY

  onContextMenu: (event) ->
    # Prevent context menu opening.
    event.preventDefault()
