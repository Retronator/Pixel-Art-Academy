AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.EditorManager
  constructor: (@pinball) ->
    @hoveredPart = new ReactiveField null
    @selectedPart = new ReactiveField null
    @draggingPart = new ReactiveField null
    @rotatingPart = new ReactiveField null
    
  editing: -> @draggingPart() or @rotatingPart()
  
  select: ->
    selectedPart = null
    
    if hoveredPart = @hoveredPart()
      selectedPart = hoveredPart if _.find Pinball.Part.getSelectablePartClasses(), (partClass) => hoveredPart instanceof partClass

    @selectedPart selectedPart
    
  addPart: (options) ->
    # Calculate target element's position in the playfield.
    elementOffset = $(options.element).offset()
    playfieldOffset = $('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield').offset()
    
    topLeftPosition = @pinball.cameraManager().transformWindowToPlayfield
      x: elementOffset.left - playfieldOffset.left
      y: elementOffset.top - playfieldOffset.top
    
    part = type: options.type
    
    # Add the node in the database.
    playfieldPartId = @_addPart part
    
    Tracker.autorun (computation) =>
      return unless part = @pinball.sceneManager().getPart playfieldPartId
      return unless shape = part.shape()
      computation.stop()
      
      pixelSize = Pinball.CameraManager.orthographicPixelSize
      
      startPosition =
        x: topLeftPosition.x + shape.bitmapOrigin.x * pixelSize
        z: topLeftPosition.z + shape.bitmapOrigin.y * pixelSize
      
      Pinball.CameraManager.snapShapeToPixelPosition shape, startPosition
      
      @startDrag part, {startPosition}

      @selectedPart part
      
  updateSelectedPart: (difference) ->
    @_updatePart @selectedPart(), difference
    
  removeSelectedPart: ->
    @_removePart @selectedPart()
    @selectedPart null

  _addPart: (partData) ->
    projectId = @pinball.projectId()
    playfieldPartId = Random.id()
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        "playfield.#{playfieldPartId}": partData
    
    playfieldPartId

  _updatePart: (part, difference) ->
    projectId = @pinball.projectId()
    partData = _.cloneDeep part.data()
    _.applyObjectDifference partData, difference
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        "playfield.#{part.playfieldPartId}": partData
    
  _removePart: (part) ->
    projectId = @pinball.projectId()
    
    PAA.Practice.Project.documents.update projectId,
      $unset:
        "playfield.#{part.playfieldPartId}": true
