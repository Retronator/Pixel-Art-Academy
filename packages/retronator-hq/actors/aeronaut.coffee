LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Aeronaut extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Aeronaut'
  @fullName: -> "Reuben 'Aeronaut' Thiessen"
  @shortName: -> "Reuben"
  @description: -> "It's Reuben Thiessen a.k.a. Aeronaut. He flew into town with his Cessna 182 Skylane."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.blue
    shade: LOI.Assets.Palette.Atari2600.characterShades.lighter

  @initialize()

  class @Listener extends LOI.Adventure.Listener
    @id: -> "Retronator.HQ.Actors.Aeronaut"

    @scriptUrls: -> [
      'retronator_retronator-hq/actors/aeronaut.script'
    ]

    class @Script extends LOI.Adventure.Script
      @id: -> "Retronator.HQ.Actors.Aeronaut"
      @initialize()

      initialize: ->
        @setCurrentThings aeronaut: HQ.Actors.Aeronaut

    @initialize()

    onScriptsLoaded: ->
      @script = @scripts[@constructor.Script.id()]

    onCommand: (commandResponse) ->
      return unless aeronaut = LOI.adventure.getCurrentThing HQ.Actors.Aeronaut

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, aeronaut]
        action: =>
          LOI.adventure.director.startScript @script
