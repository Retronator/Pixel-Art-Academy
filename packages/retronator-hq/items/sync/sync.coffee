LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Sync extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Sync'

  @fullName: -> "SYNC"

  @description: ->
    "
      It's Neurasync's Synchronization Neural Connector, SYNC for short. It looks like a fitness tracker wristband.
    "

  @initialize()
