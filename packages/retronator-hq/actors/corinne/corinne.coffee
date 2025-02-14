LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Corinne extends LOI.Character.Actor
  @id: -> 'Retronator.HQ.Actors.Corinne'
  @fullName: -> "Corinne Colgan"
  @shortName: -> "Corinne"
  @descriptiveName: -> "![Corinne](talk to Corinne) Colgan."
  @description: -> "It's Corinne Colgan, the curator of the gallery."
  @pronouns: -> LOI.Avatar.Pronouns.Feminine
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.aqua
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @defaultScriptUrl: -> 'retronator_retronator-hq/actors/corinne/corinne.script'
  @assetUrls: -> '/retronator/hq/actors/corinne'

  @initialize()

  # Listener

  @avatars: ->
    retro: HQ.Actors.Retro

  initializeScript: ->
    Tracker.autorun (computation) =>
      return unless corinne = LOI.adventure.getCurrentThing HQ.Actors.Corinne
      computation.stop()
      
      retro = @options.listener.avatars.retro

      @setThings {corinne, retro}

  onCommand: (commandResponse) ->
    return unless corinne = LOI.adventure.getCurrentThing HQ.Actors.Corinne

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, corinne]
      action: => @startScript()
