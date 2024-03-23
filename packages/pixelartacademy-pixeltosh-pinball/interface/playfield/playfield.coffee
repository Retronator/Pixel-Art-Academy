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
      'pointerdown': @onPointerDown
      'pointermove': @onPointerMove
      'pointerleave .pixelartacademy-pixeltosh-programs-pinball-interface-playfield': @onPointerLeavePlayfield
      'wheel': @onPointerWheel
      'contextmenu': @onContextMenu

  onPointerDown: (event) ->
    # Prevent browser select/dragging behavior.
    event.preventDefault()

    cameraManager = @pinball.cameraManager()
    
    switch cameraManager.displayType()
      when Pinball.CameraManager.DisplayTypes.Orthographic
        editorManager = @pinball.editorManager()
        editorManager.select()
        
        if selectedPart = editorManager.selectedPart()
          # See if the player releases the mouse button, otherwise also start dragging.
          $document = $(document)
          
          stopListening = =>
            $document.off '.pixelartacademy-pixeltosh-programs-pinball-interface-playfield'
            
          $document.on 'pointerup.pixelartacademy-pixeltosh-programs-pinball-interface-playfield', =>
            Meteor.clearTimeout @_dragTimeout
            stopListening()
            
          $document.on 'pointermove.pixelartacademy-pixeltosh-programs-pinball-interface-playfield', =>
            Meteor.clearTimeout @_dragTimeout
            stopListening()
            editorManager.startDrag selectedPart
    
      when Pinball.CameraManager.DisplayTypes.Perspective
        cameraManager.startRotateCamera event.coordinates

  onPointerMove: (event) ->
    @pinball.mouse().onMouseMove event

  onPointerLeavePlayfield: (event) ->
    @pinball.mouse().onMouseLeave event

  onPointerWheel: (event) ->
    @pinball.cameraManager().changeDistanceByFactor 1.005 ** event.originalEvent.deltaY

  onContextMenu: (event) ->
    # Prevent context menu opening.
    event.preventDefault()
