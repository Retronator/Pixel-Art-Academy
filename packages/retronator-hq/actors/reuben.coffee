LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Reuben extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Reuben'
  @fullName: -> "Reuben Thiessen"
  @shortName: -> "Reuben"
  @descriptiveName: -> "![Reuben](talk to Reuben) Thiessen."
  @description: -> "It's Reuben Thiessen a.k.a. Reuben. He flew into town with his Quest Kodiak."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.blue
    shade: LOI.Assets.Palette.Atari2600.characterShades.lighter

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/actors/reuben.script'

  initializeScript: ->
    @setCurrentThings
      reuben: HQ.Actors.Reuben

  onCommand: (commandResponse) ->
    return unless reuben = LOI.adventure.getCurrentThing HQ.Actors.Reuben

    @script.ephemeralState 'gameFinished', PAA.Season1.Episode1.Chapter1.AdmissionProjects.Snake.Drawing.finished()

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, reuben]
      action: => @startScript()
