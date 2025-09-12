LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Simplification.Silhouette extends PAA.Tutorials.Drawing.Simplification.Asset
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
      exposureValue: -1.5
  ]
  
  @initialize()
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.References
    ]
  
  Asset = @
