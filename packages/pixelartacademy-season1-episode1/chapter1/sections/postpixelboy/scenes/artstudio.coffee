LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.PostPixelBoy.ArtStudio extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy.ArtStudio'

  @location: -> HQ.ArtStudio

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/postpixelboy/scenes/artstudio.script'

  @initialize()

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      alexandra: HQ.Actors.Alexandra

    @setCallbacks
      BackToMainQuestions: (complete) =>
        # Hook back into the Reuben's main script.
        alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra
        alexandra.listeners[0].startScript label: 'MainQuestions'

        complete()

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    return unless choicePlaceholderResponse.scriptId is HQ.Actors.Alexandra.id()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestions'

    # Prerequisite is that the player has talked about pixel art software before.
    return unless HQ.Actors.Alexandra.Listener.Script.state 'SoftwareQuestions'

    labels = [
      'UsePixelBoyEditorChoice'
      'UseExternalSoftwareChoice'
    ]

    choicePlaceholderResponse.addChoice @script.startNode.labels[label].next for label in labels

    # We need to know if the player has the drawing app.
    pixelBoy = LOI.adventure.getCurrentThing PAA.PixelBoy
    hasDrawingApp = PAA.PixelBoy.Apps.Drawing in pixelBoy.os.currentAppsSituation().things()
    Tracker.nonreactive => @script.ephemeralState 'hasDrawingApp', hasDrawingApp
