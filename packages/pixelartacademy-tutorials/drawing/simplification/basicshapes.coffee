AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.Simplification.BasicShapes extends PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  @displayName: -> "Basic shapes"
  
  @description: -> """
    Simplify the shapes into their basic counterparts.
  """

  @fixedDimensions: -> width: 50, height: 50
  
  @references: -> [
    image:
      url: "/pixelartacademy/tutorials/drawing/simplification/basicshapes-scissors.glb"
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
      url: "/pixelartacademy/tutorials/drawing/simplification/basicshapes-house.glb"
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
  ]
  
  @goalChoices: -> [
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/basicshapes-scissors.glb"
    information:
      fill: true
  ,
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/basicshapes-house.glb"
  ]
  
  @initialize()
  
  @meshMorphingInstructions = true
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    # Create line art drawing step.
    new PAA.Tutorials.Drawing.Simplification.ModelStep @, stepArea,
      fill: stepResources.information?.fill
      drawHintsAfterCompleted: false
      tolerance: 1
      strokeStyle: if stepResources.information?.fill then TutorialBitmap.PathStep.StrokeStyles.None else TutorialBitmap.PathStep.StrokeStyles.Solid
      svgPaths: => # Dummy function to trigger reactive path generation.
  
  Asset = @
  
  class @SilhouetteStep extends PAA.Tutorials.Drawing.Simplification.ModelStep
    @style: -> 'opacity:1;fill:#000000;stroke:#000000;stroke-width:0.1;stroke-linecap:square;stroke-linejoin:bevel'
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction
    getMeshMorphing: ->
      return unless stepAreaData = @getStepArea()?.data()
      return unless asset = @getActiveAsset()
      return unless bitmapReferences = asset.bitmap()?.references
      return unless referenceData = _.find bitmapReferences, (reference) => reference.image.url is stepAreaData.referenceUrl
      referenceData.displayOptions?.meshMorphing
  
  class @AdjustAmount extends @Instruction
    @id: -> "#{Asset.id()}.AdjustAmount"
    @assetClass: -> Asset
    
    @message: -> """
      Hover over the center of the reference image and drag to simplify the object's shapes.
    """
    
    @initialize()
  
    activeConditions: ->
      return unless @stepAreaActive()
      not @getMeshMorphing()
