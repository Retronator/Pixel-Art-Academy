LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Corinne extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Corinne'
  @fullName: -> "Corinne Colgan"
  @shortName: -> "Corinne"
  @description: -> "It's Corinne Colgan, Retronator Gallery™ curator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.aqua
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/actors/corinne.script'

  initializeScript: ->
    @setCurrentThings
      corinne: HQ.Actors.Corinne

  onCommand: (commandResponse) ->
    return
    
    # TODO: Enable Corinne's conversation.
    return unless corinne = LOI.adventure.getCurrentThing HQ.Actors.Corinne

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, corinne]
      action: => @startScript()
