LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Coworking.Reuben extends HQ.Actors.Reuben
  @defaultScriptUrl: -> 'retronator_retronator-hq/floor1/coworking/reuben.script'
  @defaultScriptId: -> 'Retronator.HQ.Coworking.Reuben'

  @initialize()

  initializeScript: ->
    @setCurrentThings
      reuben: HQ.Actors.Reuben

  onCommand: (commandResponse) ->
    return unless reuben = LOI.adventure.getCurrentThing HQ.Actors.Reuben

    @script.ephemeralState 'gameFinished', PAA.Season1.Episode1.Chapter1.AdmissionProjects.Snake.Drawing.finished()

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, reuben]
      action: => @startScript()
