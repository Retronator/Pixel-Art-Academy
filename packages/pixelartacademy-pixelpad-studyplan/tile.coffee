AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.TileMap.Tile
  @Types =
    BlueprintEdge: 'BlueprintEdge'
    Blueprint: 'Blueprint'
    Ground: 'Ground'
    Sidewalk: 'Sidewalk'
    Road: 'Road'
    Building: 'Building'
    Gate: 'Gate'
    Flag: 'Flag'
    ExpansionPoint: 'ExpansionPoint'
    
  @ExpansionDirections =
    Forward: 'Forward'
    Backwards: 'Backwards'
    Sideways: 'Sideways'

  constructor: (x, y) ->
    @position = new THREE.Vector2 x, y
