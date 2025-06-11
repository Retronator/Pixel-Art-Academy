AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences extends PAA.Tutorials.Drawing.Design.ShapeLanguage.Asset
  @referenceNames: -> throw new AE.NotImplementedException "Asset with references must provide reference names."

  @createReferenceUrl: (fileName) -> @createResourceUrl "#{fileName}.png"
  
  @customPaletteImageUrl: -> @createLessonResourceUrl "template.png"
  
  @references: ->
    for name in @referenceNames()
      image:
        url: @createReferenceUrl name
      displayOptions:
        imageOnly: true
  
  @resources: ->
    goalChoices:
      for name in @referenceNames()
        referenceUrl: @createReferenceUrl name
        step1: new @Resource.SvgPaths @createLessonResourceUrl "#{name}.svg"
        step2: new @Resource.ImagePixels @createLessonResourceUrl "#{name}-1.png"
        step3: new @Resource.ImagePixels @createLessonResourceUrl "#{name}-2.png"
  
  _initialize: ->
    super arguments...
    
    references = @constructor.references()
    
    # Disable and enable ramp shades depending if the reference has been chosen.
    @enabledPaletteRampIndices = new AE.LiveComputedField =>
      return [] unless assetData = @getAssetData()
      enabledPaletteRampIndices = []
      
      if stepAreas = assetData.stepAreas
        for stepArea in stepAreas
          referenceIndex = _.findIndex references, (reference) => reference.image.url is stepArea.referenceUrl
          enabledPaletteRampIndices.push referenceIndex
      
      enabledPaletteRampIndices
    ,
      EJSON.equals

    @_enabledPaletteRampsAutorun = Tracker.autorun (computation) =>
      return unless @initialized() and @resourcesReady()
      enabledPaletteRampIndices = @enabledPaletteRampIndices()
      
      Tracker.nonreactive => Tracker.afterFlush =>
        return unless bitmapId = @bitmapId()
        bitmapData = LOI.Assets.Bitmap.documents.findOne bitmapId, fields: customPalette: 1
        
        changed = false
        
        for ramp, rampIndex in bitmapData.customPalette.ramps
          if rampIndex in enabledPaletteRampIndices and not ramp.shades.length
            changed = true
            ramp.shades = ramp.disabledShades
            
          if ramp.shades.length and rampIndex not in enabledPaletteRampIndices
            changed = true
            ramp.disabledShades = ramp.shades
            ramp.shades = []
            
        return unless changed
        
        # Update persistent document.
        bitmapData.lastEditTime = new Date()
        LOI.Assets.Bitmap.documents.update bitmapId, $set: bitmapData
        
        # Trigger reactivity.
        LOI.Assets.Bitmap.versionedDocuments.reportNonVersionedChange bitmapId

  destroy: ->
    super arguments...
    
    @enabledPaletteRampIndices?.stop()
    @_enabledPaletteRampsAutorun?.stop()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    # Create shapes step.
    new @constructor.PathStep @, stepArea,
      svgPaths: stepResources.step1.svgPaths()
      preserveCompleted: true
      hasPixelsWhenInactive: false
      
    # Create silhouette step.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: stepResources.step2
      preserveCompleted: true
      hasPixelsWhenInactive: false
      
    # Create colors step.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: stepResources.step3
      hasPixelsWhenInactive: false
