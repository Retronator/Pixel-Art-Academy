AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Simplification.DefiningFeatures extends PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  @displayName: -> "Defining features"
  
  @description: -> """
    When simplifying, choose the most essential, signature parts of an object to draw.
  """

  @fixedDimensions: -> width: 50, height: 50
  
  @references: -> [
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/definingfeatures-pizza.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        meshVisibility: true
      background:
        color: "#808080"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/studio_small_08_1k.hdr"
      camera:
        frustum:
          width: 0.2
          height: 0.2
      meshVisibility:
        amountVisible: 1
        sizePreference: 0.5
        sizeMeasurementAxes:
          x: true
          z: true
  ,
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/definingfeatures-house.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        meshVisibility: true
      background:
        color: "#92c1e3"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/symmetrical_garden_1k.hdr"
      camera:
        frustum:
          width: 110
          height: 110
        zNear: 1
        zFar: 1000
        radialDistance: 100
        polarAngle: AR.Degrees 90
        azimuthalAngle: -AR.Degrees 90
      meshVisibility:
        amountVisible: 1
        sizePreference: 0.5
        sizeMeasurementAxes:
          y: true
          z: true
  ,
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/definingfeatures-boombox.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        meshVisibility: true
      background:
        color: "#808080"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/studio_small_08_1k.hdr"
      camera:
        frustum:
          width: 1
          height: 1
        polarAngle: AR.Degrees 90
        radialDistance: 2
      exposureValue: 0.5
      meshVisibility:
        amountVisible: 1
        sizePreference: 0.5
        sizeMeasurementAxes:
          x: true
          y: true
  ]
  
  @goalChoices: -> [
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/definingfeatures-pizza.glb"
  ,
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/definingfeatures-house.glb"
  ,
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/definingfeatures-boombox.glb"
  ]
  
  @initialize()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    # Create line art drawing step.
    new @constructor.LineArtStep @, stepArea,
      drawHintsAfterCompleted: false
      tolerance: 1
      svgPaths: => # Dummy function to trigger reactive path generation.
  
  Asset = @
  
  class @LineArtStep extends PAA.Tutorials.Drawing.Simplification.ModelStep
    @meshSelector: (object) -> object instanceof THREE.Mesh and object.visible

  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction
    getMeshVisibility: ->
      return unless stepAreaData = @getStepArea()?.data()
      return unless asset = @getActiveAsset()
      return unless bitmapReferences = asset.bitmap()?.references
      return unless referenceData = _.find bitmapReferences, (reference) => reference.image.url is stepAreaData.referenceUrl
      referenceData.displayOptions?.meshVisibility
  
    getLiveMeshVisibility: ->
      return unless stepAreaData = @getStepArea()?.data()
      return unless drawingEditor = @getEditor()
      return unless referencesView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.References
      return unless referenceComponent = referencesView.displayComponent.getReferenceComponentForUrl stepAreaData.referenceUrl
      return unless sceneManager = referenceComponent.sceneManager()
      sceneManager.meshVisibilityProperties()
  
    activeConditions: ->
      # Show modification instructions while input is active on the reference.
      return unless @stepAreaActive()
      return unless stepAreaData = @getStepArea()?.data()
      return unless asset = @getActiveAsset()
      return unless referenceData = asset.getReferenceDataForUrl stepAreaData.referenceUrl
      referenceData.displayOptions?.input
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
      
  class @AdjustAmount extends @Instruction
    @id: -> "#{Asset.id()}.AdjustAmount"
    @assetClass: -> Asset
    
    @message: -> """
      Hover over the center of the reference image and drag left and right to change how many parts of the object are visible.
    """
    
    @priority: -> 2
    
    @initialize()
  
    completedConditions: ->
      return unless @stepAreaActive()
      @getMeshVisibility()
  
  class @AdjustSizePreference extends @Instruction
    @id: -> "#{Asset.id()}.AdjustSizePreference"
    @assetClass: -> Asset
    
    @message: -> """
      Drag up and down on the reference to change which details get removed.
    """
    
    @priority: -> 1
    
    @initialize()
    
    completedConditions: ->
      return unless @stepAreaActive()
      return unless meshVisibility = @getLiveMeshVisibility()
      meshVisibility.sizePreference in [0, 1]
    
  class @Draw extends @Instruction
    @id: -> "#{Asset.id()}.Draw"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the lines when you are happy with the look of the object.
    """
    
    @initialize()
