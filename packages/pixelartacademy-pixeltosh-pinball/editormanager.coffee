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
    
    # Whenever a new project is loaded, clean up any previous editor errors.
    @previousProjectId = new ReactiveField null
    
    @_projectChangeAutorun = Tracker.autorun (computation) =>
      return unless projectId = @pinball.projectId()
      
      # Only clean up the currently active project.
      return unless projectId is Pinball.Project.state 'activeProjectId'
      
      Tracker.nonreactive =>
        previousProjectId = @previousProjectId()
        return if projectId is previousProjectId
        
        @_cleanupAutorun = Tracker.autorun (computation) =>
          return unless project = PAA.Practice.Project.documents.findOne projectId
          computation.stop()
          
          # Remove any invalid parts.
          for partId, part of project.playfield
            # A valid part has a known type and position.
            continue if Pinball.Part.getClassForId(part.type) and part.position
            
            @removePartByPlayfieldId partId
            
          # Add the plunger if it's missing and you can't edit the playfield yet.
          unless @pinball.editModeUnlocked()
            plungerFound = false
            for partId, part of project.playfield when part.type is Pinball.Parts.Plunger.id()
              plungerFound = true
              break
            
            unless plungerFound
              pixelSize = Pinball.CameraManager.orthographicPixelSize
              
              PAA.Practice.Project.documents.update projectId,
                $set:
                  "playfield.#{Random.id()}":
                    type: Pinball.Parts.Plunger.id()
                    position:
                      x: 173.5 * pixelSize
                      z: 189.5 * pixelSize
                  lastEditTime: new Date
                  
          # Re-link any missing assets up to the current task.
          PinballGoal = LM.PixelArtFundamentals.Fundamentals.Goals.Pinball
          
          for taskClass, taskIndex in PinballGoal.tasks()
            
            if taskClass.prototype instanceof PinballGoal.AssetsTask
              assetsMissing = false
              
              for assetClass in taskClass.unlockedAssets()
                assetId = assetClass.id()
                continue if _.find project.assets, (asset) => asset.id is assetId

                console.warn "Missing pinball asset detected! Trying to find an existing one …", assetId
                
                # See if there is a bitmap available with this asset's name.
                name = assetClass.displayName()
                fixedDimensions = assetClass.fixedDimensions()
                
                existingBitmap = LOI.Assets.Bitmap.documents.findOne
                  name: name
                  'bounds.width': fixedDimensions.width
                  'bounds.height': fixedDimensions.height
                  
                if existingBitmap
                  console.warn "Found it! Adding it to the project.", existingBitmap._id
                  
                  PAA.Practice.Project.documents.update projectId,
                    $push:
                      assets:
                        id: assetId
                        type: 'Bitmap'
                        bitmapId: existingBitmap._id
                    $set:
                      lastEditTime: new Date
                      
                else
                  console.warn "Could not found it."
                  assetsMissing = true
                  
              if assetsMissing
                # Some assets weren't found as existing bitmaps so we reactivate the task.
                console.warn "Some assets were not found. Reactivating asset creation."
                taskClass.onActive()
                
            if taskClass.getAdventureInstance().active()
              break
      
  destroy: ->
    @_projectChangeAutorun.stop()
    @_cleanupAutorun?.stop()
    @_addPartAutorun?.stop()
    
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
    
    @_addPartAutorun = Tracker.autorun (computation) =>
      return unless part = @pinball.sceneManager()?.getPart playfieldPartId
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

  removePart: (part) -> @removePartByPlayfieldId part.playfieldPartId

  removePartByPlayfieldId: (playfieldPartId) ->
    projectId = @pinball.projectId()
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        lastEditTime: new Date
      $unset:
        "playfield.#{playfieldPartId}": true
  
  updateSelectedPart: (difference) ->
    @updatePart @selectedPart(), difference
  
  removeSelectedPart: ->
    @removePart @selectedPart()
    @selectedPart null
