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
    $element = $(options.element)
    elementOffset = $element.offset()
    playfieldOffset = $('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield').offset()
    
    # Place the new part in the center of the element from the parts view.
    # TODO: Take into account that the origin is not always in the center of the element.
    startPosition = @pinball.cameraManager().transformWindowToPlayfield
      x: elementOffset.left - playfieldOffset.left + $element.outerWidth() / 2
      y: elementOffset.top - playfieldOffset.top + $element.outerHeight() / 2
    
    projectId = @pinball.projectId()
    playfieldPartId = Random.id()
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        "playfield.#{playfieldPartId}":
          type: options.type
        lastEditTime: new Date
    
    Tracker.autorun (computation) =>
      return unless part = @pinball.sceneManager().getPart playfieldPartId
      return unless shape = part.shape()
      computation.stop()
      
      Pinball.CameraManager.snapShapeToPixelPosition shape, startPosition, new THREE.Quaternion
      
      @startDrag part, {startPosition}

      @selectedPart part

  updatePart: (part, difference) ->
    projectId = @pinball.projectId()
    partData = _.cloneDeep part.data()
    _.applyObjectDifference partData, difference
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        "playfield.#{part.playfieldPartId}": partData
        lastEditTime: new Date
    
  removePart: (part) ->
    projectId = @pinball.projectId()
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        lastEditTime: new Date
      $unset:
        "playfield.#{part.playfieldPartId}": true
  
  updateSelectedPart: (difference) ->
    @updatePart @selectedPart(), difference
  
  removeSelectedPart: ->
    @removePart @selectedPart()
    @selectedPart null
