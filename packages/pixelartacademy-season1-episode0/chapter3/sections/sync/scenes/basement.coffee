LOI = LandsOfIllusions
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ
RA = Retronator.Accounts

Vocabulary = LOI.Parser.Vocabulary

class C3.Sync.Basement extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.Sync.Basement'
  @location: -> HQ.Basement

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter3/sections/sync/scenes/basement.script'

  # Script

  initializeScript: ->
    @setCurrentThings
      operator: HQ.Actors.Operator

  # Listener

  onCommand: (commandResponse) ->
    return unless operator = LOI.adventure.getCurrentThing HQ.Actors.Operator

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, operator.avatar]
      priority: 1
      action: => @startScript()
