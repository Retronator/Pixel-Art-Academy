AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @CanvasExtensionDirection =
    Horizontal: 'Horizontal'
    Vertical: 'Vertical'

  # Override to provide reference images that need to be added to the bitmap.
  @references: -> null
  
  # Override to specify how using multiple references should resize the canvas.
  @canvasExtensionDirection: -> @CanvasExtensionDirection.Horizontal
  
  @initializeReferences: ->
    return unless references = @references()
    
    # Create reference images on the server. They should be exported as database content.
    if Meteor.isServer and not Meteor.settings.startEmpty
      Document.startup =>
        for reference in references
          # Allow sending in just the reference URL.
          imageUrl = reference.image?.url or reference
    
          LOI.Assets.Image.documents.insert url: imageUrl unless LOI.Assets.Image.documents.findOne url: imageUrl
          
  getReferenceDataForUrl: (url) ->
    return unless bitmapReferences = @bitmap()?.references
    defaultReferencesData = @constructor.references()
    
    return unless data = _.find bitmapReferences, (reference) => reference.image.url is url
    return unless defaultData = _.find defaultReferencesData, (reference) => reference.image.url is url
    
    _.defaultsDeep {}, data, defaultData
    
  _initialize: ->
    super arguments...
    
    return unless references = @constructor.references()
    return unless goalChoices = @resources.goalChoices
    
    referenceUrlChoices = (goalChoice.referenceUrl for goalChoice in goalChoices)

    @displayedReferenceUrlChoices = new AE.LiveComputedField =>
      return unless bitmap = @bitmap()
      return unless references = bitmap.references
      displayedReferences = _.filter references, (reference) => reference.displayed and reference.image.url in referenceUrlChoices
      
      # Track URLs and whether this is the initial state, so we can react to
      # a reset of a bitmap that had its references hidden before reset.
      urls: (reference.image.url for reference in displayedReferences)
      initialState: not @bitmap()?.historyPosition
    ,
      EJSON.equals
 
    # Update step areas and resize the bitmap accordingly if needed.
    @_chosenReferencesAutorun = Tracker.autorun (computation) =>
      return unless @initialized() and @resourcesReady()
      return unless displayedReferenceUrlChoices = @displayedReferenceUrlChoices()
      
      Tracker.nonreactive => Tracker.afterFlush =>
        return unless bitmapId = @bitmapId()
        return unless bitmap = @bitmap()
        
        # Prevent recomputation of completed states while resetting.
        @resetting true

        # Note: Create clones since they get compared for equality.
        assetData = _.clone @data()
        oldStepAreas = assetData.stepAreas
        stepAreas = if oldStepAreas then _.clone oldStepAreas else []
        
        # Remove references at the end that haven't been drawn on yet.
        fixedDimensions = @constructor.fixedDimensions()
        singleWidth = fixedDimensions.width
        singleHeight = fixedDimensions.height
        horizontalExtension = @constructor.canvasExtensionDirection() is @constructor.CanvasExtensionDirection.Horizontal
        
        removeNeeded = false
        
        for stepArea in stepAreas when stepArea.referenceUrl not in displayedReferenceUrlChoices.urls
          removeNeeded = true
          break
        
        if removeNeeded
          for stepArea, index in stepAreas by -1
            startX = 0
            startY = 0
            
            if horizontalExtension
              startX = index * singleWidth
              
            else
              startY = index * singleHeight
            
            found = false
            for x in [0...singleWidth]
              for y in [0...singleHeight]
                if bitmap.findPixelAtAbsoluteCoordinates startX + x, startY + y
                  found = true
                  break
                  
              break if found
              
            # Stop removing unused references since the player has already drawn here.
            break if found
            
            # The player hasn't drawn so far, so if we don't want the reference anymore, we can remove it.
            if stepArea.referenceUrl not in displayedReferenceUrlChoices.urls
              _.pull stepAreas, stepArea
        
        # Add new step areas.
        for referenceUrl in displayedReferenceUrlChoices.urls
          stepAreas.push {referenceUrl} unless _.find stepAreas, (stepArea) => stepArea.referenceUrl is referenceUrl
        
        # Track which references are used to recreate step areas (displayed and already drawn hidden ones).
        stepAreaReferenceUrls = (stepArea.referenceUrl for stepArea in stepAreas)

        # See if we need to write new changes.
        if EJSON.equals stepAreas, oldStepAreas
          # Step areas data is already correct. Do we need to still initialize the areas?
          if EJSON.equals stepAreaReferenceUrls, @_currentStepAreaReferenceUrls
            @resetting false
            return

        else
          # We have new step areas data. Save it before initializing new step areas.
          assetData.stepAreas = stepAreas
          @setAssetData assetData

        @_currentStepAreaReferenceUrls = stepAreaReferenceUrls

        # If necessary, resize the bitmap to make space for all the chosen references.
        desiredWidth = singleWidth
        desiredHeight = singleHeight
        
        if horizontalExtension
          desiredWidth = singleWidth * Math.max 1, stepAreas.length
          
        else
          desiredHeight = singleHeight * Math.max 1, stepAreas.length
          
        bitmap = Tracker.nonreactive => LOI.Assets.Bitmap.documents.findOne bitmapId, fields: bounds: 1
        width = bitmap.bounds.right - bitmap.bounds.left + 1
        height = bitmap.bounds.bottom - bitmap.bounds.top + 1
        
        unless desiredWidth is width and desiredHeight is height
          bitmap = Tracker.nonreactive => LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId

          # Create a change bounds action.
          changeBounds = new LOI.Assets.Bitmap.Actions.ChangeBounds @id(), bitmap,
            left: 0
            top: 0
            right: desiredWidth - 1
            bottom: desiredHeight - 1
            fixed: true
            
          bitmap.executeAction changeBounds, true

        # Change step area instances.
        stepAreaInstances = @stepAreas()
        @stepAreas []
        stepAreaInstance.destroy() for stepAreaInstance in stepAreaInstances
        
        for stepArea, index in stepAreas
          stepAreaBounds =
            x: 0
            y: 0
            width: singleWidth
            height: singleHeight
            
          if horizontalExtension
            stepAreaBounds.x = index * singleWidth
            
          else
            stepAreaBounds.y = index * singleHeight
          
          stepAreaInstance = new @constructor.StepArea @, stepAreaBounds
  
          if goalChoice = _.find goalChoices, (goalChoice) => goalChoice.referenceUrl is stepArea.referenceUrl
            @initializeStepsInAreaWithResources stepAreaInstance, goalChoice
            stepAreaInstance.initialize()
        
        # Unlock recomputation after changes have been applied.
        Tracker.afterFlush => @resetting false

  destroy: ->
    super arguments...
    
    @displayedReferenceUrlChoices?.stop()
    @assetStepAreas?.stop()
    @_chosenReferencesAutorun?.stop()
    @_referenceStepsAutorun?.stop()

  referenceDefaults: ->
    return {} unless references = @constructor.references()
    
    defaults = {}
    
    # Add reference data to defaults (make sure an object and not just an URL is given).
    for reference in references when _.isObject reference
      defaults[reference.image.url] = reference
      
    defaults

  displayRandomReference: ->
    return unless goalChoices = @resources.goalChoices
    return unless bitmapId = @bitmapId()
    return unless bitmap = @bitmap()
    return unless bitmap.references?.length

    # Nothing to do if a reference is already displayed.
    return unless displayedReferenceUrlChoices = @displayedReferenceUrlChoices?()
    return true if displayedReferenceUrlChoices.urls.length

    # Choose among the references that have goal choices, since only those can create step areas.
    referenceUrlChoices = (goalChoice.referenceUrl for goalChoice in goalChoices when goalChoice.referenceUrl)
    availableReferences = _.filter bitmap.references, (reference) => reference.image?.url in referenceUrlChoices
    return unless availableReferences.length

    versionedBitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId

    referenceIndex = Math.floor Math.random() * availableReferences.length
    reference = availableReferences[referenceIndex]

    updateReferenceAction = new LOI.Assets.VisualAsset.Actions.UpdateReference @id(), versionedBitmap, reference.image._id, displayed: true
    versionedBitmap.executeAction updateReferenceAction

    true
