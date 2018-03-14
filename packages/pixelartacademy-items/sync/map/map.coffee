AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.Sync.Map extends PAA.Items.Sync.Tab
  @id: -> 'Retronator.PAA.Items.Sync.Map'
  @register @id()

  @url: -> 'map'
  @displayName: -> 'Map'
    
  @initialize()

  onCreated: ->
    super

    @map = new PAA.Items.Components.Map
