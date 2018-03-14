AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.Sync.Memories extends PAA.Items.Sync.Tab
  @id: -> 'Retronator.PAA.Items.Sync.Memories'
  @register @id()

  @url: -> 'memories'
  @displayName: -> 'Memories'

  @initialize()

  onCreated: ->
    super
