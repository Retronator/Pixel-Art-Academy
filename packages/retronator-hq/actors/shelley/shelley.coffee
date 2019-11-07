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

  @defaultScriptUrl: -> 'retronator_retronator-hq/actors/shelley/shelley.script'
  @assetUrls: -> '/retronator/hq/actors/shelley'

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
        # Provide application read-only state.
        application = PixelArtAcademy.Season1.Episode1.Chapter1.readOnlyState 'application'

        # Note: We need to make sure the application object exists since we'll be accessing its fields from the script.
        @script.ephemeralState 'application', application or {}

        # Immersion has been completed after chapter 2 is done or implicitly if we're synced to a character.
        @script.ephemeralState 'immersionDone', PixelArtAcademy.Season1.Episode0.Chapter2.finished() or LOI.characterId()

        @startScript()
