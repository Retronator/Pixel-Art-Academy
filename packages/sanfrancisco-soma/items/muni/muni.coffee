LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Items.Muni extends LOI.Adventure.Item
  @id: -> 'SanFrancisco.Soma.Items.Muni'

  @version: -> '0.0.1'

  @fullName: -> "T Third Street Muni train"
  @shortName: -> "Muni train"
  @description: ->
    "
      It's the line T Muni train that rides north-south through SOMA. You can ![use](use muni) it to fast-travel.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-soma/items/muni/muni.script'

  @initialize()

  # Script

  initializeScript: ->
    @setCallbacks
      Travel: (complete) ->
        LOI.adventure.goToLocation @ephemeralState().destinationId

  # Listener

  onCommand: (commandResponse) ->
    muni = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, muni.avatar]
      action: => @startScript()
