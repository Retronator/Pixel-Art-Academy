AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.Tool extends LOI.Assets.Editor.Tools.Tool
  @icon: -> "/landsofillusions/assets/mesheditor/tools/#{_.kebabCase @displayName()}.png"

  onMouseMove: (event) ->
    super arguments...
    
    @pixelCoordinate = @editor().mouse().pixelCoordinate()
