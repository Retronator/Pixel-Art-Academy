LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Sync extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Sync'

  @fullName: -> "SYNC"

  @description: ->
    "
      It's Neurasync's Synchronization Neural Connector, SYNC for short. It looks like a fitness tracker wristband.
    "

  @initialize()

  # Listener

  onCommand: (commandResponse) ->
    sync = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, sync.avatar]
      action: =>
        LOI.adventure.getCurrentThing(HQ.Items.OperatorLink).start()
