AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.Simplification.StylizedProportions extends PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  @displayName: -> "Stylized proportions"
  
  @description: -> """
    You can change the sizes of the object's parts to achieve more clarity.
  """

  @fixedDimensions: -> width: 50, height: 50
  
  @references: -> [
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/stylizedproportions-scissors.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        meshMorphing:
          horizontal: "Key 1"
      background:
        color: "#808080"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/studio_small_03_1k.hdr"
      camera:
        fieldOfView: 40
        radialDistance: 0.3
        azimuthalAngle: AR.Degrees -90
      exposureValue: -1.5
      meshMorphing:
        "Key 1": 0
  ,
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/stylizedproportions-house.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        meshMorphing:
          horizontal: "Key 1"
      background:
        color: "#92c1e3"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/symmetrical_garden_1k.hdr"
      camera:
        frustum:
          width: 105
          height: 105
        zNear: 1
        zFar: 1000
        radialDistance: 100
        polarAngle: AR.Degrees 90
        azimuthalAngle: -AR.Degrees 90
      meshMorphing:
        "Key 1": 0
  ,
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/stylizedproportions-clock.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        meshMorphing:
          horizontal: "Key 1"
      background:
        color: "#808080"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/studio_small_03_1k.hdr"
      camera:
        frustum:
          width: 0.18
          height: 0.18
        polarAngle: AR.Degrees 90
      exposureValue: -0.5
      meshMorphing:
        "Key 1": 0
  ]
  
  @goalChoices: -> [
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/stylizedproportions-scissors.glb"
    information:
      fill: true
  ,
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/stylizedproportions-house.glb"
  ,
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/stylizedproportions-clock.glb"
  ]
  
  @meshMorphingInstructions = true
  
  @initialize()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    # Create line art drawing step.
    new PAA.Tutorials.Drawing.Simplification.ModelStep @, stepArea,
      fill: stepResources.information?.fill
      drawHintsAfterCompleted: false
      tolerance: 1
      strokeStyle: if stepResources.information?.fill then TutorialBitmap.PathStep.StrokeStyles.None else TutorialBitmap.PathStep.StrokeStyles.Solid
      svgPaths: => # Dummy function to trigger reactive path generation.
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
    ]
    
  Asset = @
  
  class @AdjustAmount extends PAA.Tutorials.Drawing.Simplification.MeshMorphingInstruction
    @id: -> "#{Asset.id()}.AdjustAmount"
    @assetClass: -> Asset
    
    @message: -> """
      Hover over the center of the reference image and drag to simplify the object's proportions.
    """
    
    @initialize()
  
    activeConditions: ->
      return unless @stepAreaActive()
      not @getMeshMorphing()
