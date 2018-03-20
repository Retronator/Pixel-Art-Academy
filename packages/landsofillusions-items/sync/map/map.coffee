AC = Artificial.Control
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Items.Sync.Map extends LOI.Items.Sync.Tab
  @id: -> 'LandsOfIllusions.Items.Sync.Map'
  @register @id()

  @url: -> 'map'
  @displayName: -> 'Map'
    
  @initialize()

  onCreated: ->
    super

    @map = new LOI.Items.Components.Map
