AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.Simplification.Silhouette extends PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  @displayName: -> "Silhouette"
  
  @description: -> """
    One place to start simplification is to draw the object's most recognizable shape.
  """

  @fixedDimensions: -> width: 50, height: 50
  
  @references: -> [
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/silhouette-scissors.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        rotate: true
      background:
        color: "#808080"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/studio_small_03_1k.hdr"
      camera:
        fieldOfView: 40
        radialDistance: 0.25
        polarAngle: AR.Degrees 90
      exposureValue: -1.5
  ,
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/silhouette-house.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        rotate: true
      background:
        color: "#92c1e3"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/symmetrical_garden_1k.hdr"
      camera:
        frustum:
          width: 150
          height: 150
        zNear: 1
        zFar: 1000
        radialDistance: 100
  ,
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/silhouette-ship.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        rotate: true
      background:
        color: "#92c1e3"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/qwantani_noon_puresky_1k.hdr"
      camera:
        frustum:
          width: 45
          height: 45
        zNear: 1
        zFar: 1000
        radialDistance: 100
      exposureValue: -0.5
  ]
  
  @goalChoices: -> [
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/silhouette-scissors.glb"
    information:
      goalRotation:
        azimuthalAngle: AR.Degrees 0
        polarAngle: AR.Degrees 0
        angleTolerance: AR.Degrees 30
  ,
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/silhouette-house.glb"
    information:
      goalRotation:
        azimuthalAngle: AR.Degrees 90
        polarAngle: AR.Degrees 90
        angleTolerance: AR.Degrees 10
  ,
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/silhouette-ship.glb"
    information:
      goalRotation:
        azimuthalAngle: AR.Degrees 90
        polarAngle: AR.Degrees 90
        angleTolerance: AR.Degrees 20
  ]
  
  @initialize()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    # Create reference rotation step.
    new @constructor.RotateStep @, stepArea,
      fill: true
      goalRotation: stepResources.information.goalRotation
      strokeStyle: TutorialBitmap.PathStep.StrokeStyles.None
      fillStyle: TutorialBitmap.PathStep.FillStyles.Solid
      svgPaths: => # Dummy function to trigger reactive path generation.
    
    # Create silhouette drawing step.
    new PAA.Tutorials.Drawing.Simplification.ModelStep @, stepArea,
      fill: true
      drawHintsAfterCompleted: false
      tolerance: 1
      strokeStyle: TutorialBitmap.PathStep.StrokeStyles.None
      svgPaths: => # Dummy function to trigger reactive path generation.
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
    ]
  
  Asset = @

  class @Adjust extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @id: -> "#{Asset.id()}.Adjust"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      Hover over the center of the reference image and drag to rotate the object. Choose a rotation that clearly describes the object just from its outline.
    """
    
    @initialize()

  class @Draw extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @id: -> "#{Asset.id()}.Draw"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      Fill in the object's silhouette to represent the object.
    """
    
    activeConditions: ->
      return unless super arguments...
      
      # Show instruction while input is active on the reference.
      return unless stepAreaData = @getStepArea()?.data()
      return unless asset = @getActiveAsset()
      return unless referenceData = asset.getReferenceDataForUrl stepAreaData.referenceUrl
      referenceData.displayOptions?.input
      
    @initialize()
  
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Multiarea.CompletedInstruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      With a clear silhouette, we don't even need to add inner details for the object to be recognizable.
    """
    
    @initialize()
