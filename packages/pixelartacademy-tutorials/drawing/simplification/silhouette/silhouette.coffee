AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Simplification.Silhouette extends PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  @displayName: -> "Silhouette"
  
  @description: -> """
    One way to simplify an object and achieve clarity is to draw its most recognizable shape.
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
  ]
  
  @goalChoices: -> [
    referenceUrl: "/pixelartacademy/tutorials/drawing/simplification/silhouette-scissors.glb"
    information:
      goalRotation:
        azimuthalAngle: 0
        polarAngle: 0
  ]
  
  @initialize()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    # Create reference rotation step.
    new @constructor.RotateStep @, stepArea,
      goalRotation: stepResources.information.goalRotation
    
    # Create silhouette drawing step.
    new @constructor.SilhouetteStep @, stepArea,
      drawHintsAfterCompleted: false
      tolerance: 1
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
    
    @initialize()
  
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Multiarea.CompletedInstruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      With a clear silhouette, we don't even need to add details for the object to be recognizable.
    """
    
    @initialize()
