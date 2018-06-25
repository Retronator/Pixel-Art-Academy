LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Aeronaut extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Aeronaut'
  @fullName: -> "Reuben 'Aeronaut' Thiessen"
  @shortName: -> "Reuben"
  @description: -> "It's Reuben Thiessen a.k.a. Aeronaut. He flew into town with his Quest Kodiak."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.blue
    shade: LOI.Assets.Palette.Atari2600.characterShades.lighter

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/actors/aeronaut.script'

  initializeScript: ->
    @setCurrentThings
      aeronaut: HQ.Actors.Aeronaut

  onCommand: (commandResponse) ->
    return unless aeronaut = LOI.adventure.getCurrentThing HQ.Actors.Aeronaut

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, aeronaut]
      action: => @startScript()
