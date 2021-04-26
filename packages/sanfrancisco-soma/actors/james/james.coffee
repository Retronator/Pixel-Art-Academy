LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Actors.James extends LOI.Adventure.Thing
  @id: -> 'SanFrancisco.Soma.Actors.James'
  @fullName: -> "James Newnorth"
  @shortName: -> "James"
  @description: ->
    "
      It's James Newnorth, the founder of Spelkollektivet, the biggest coliving space for indie game developers.
    "
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.lime
    shade: LOI.Assets.Palette.Atari2600.characterShades.lighter

  @defaultScriptUrl: -> 'retronator_sanfrancisco-soma/actors/james/james.script'

  @initialize()

  # Script

  initializeScript: ->
    @setCurrentThings
      james: Soma.Actors.James

  # Listener

  onCommand: (commandResponse) ->
    james = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, james]
      action: => @startScript()
