LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Shelley extends LOI.Character.Actor
  @id: -> 'Retronator.HQ.Actors.Shelley'
  @fullName: -> "Shelley Williamson"
  @shortName: -> "Shelley"
  @descriptiveName: -> "![Shelley](talk to Shelley) Williamson."
  @description: -> "It's Shelley Williamson, Retro's art agent."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.brown
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @defaultScriptUrl: -> 'retronator_retronator-hq/actors/shelley.script'
  @nonPlayerCharacterDocumentUrl: -> 'retronator_retronator-hq/actors/shelley.json'
  @textureUrls: -> '/retronator/hq/actors/shelley'

  @initialize()

  # Script

  initializeScript: ->
    @setCurrentThings
      shelley: HQ.Actors.Shelley
      coordinator: HQ.Actors.Shelley

  # Listener

  onCommand: (commandResponse) ->
    return unless shelley = LOI.adventure.getCurrentThing HQ.Actors.Shelley

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, shelley]
      action: =>
        C1 = PixelArtAcademy.Season1.Episode1.Chapter1

        @script.ephemeralState 'application',
          applied: C1.state('application')?.applied
          accepted: C1.readOnlyState('application')?.accepted

        @startScript()
