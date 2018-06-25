LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.AdmissionProjects.Snake.Drawing.Coworking extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects.Snake.Drawing.Coworking'

  @location: -> HQ.Coworking

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/admissionprojects/snake/drawing/scenes/coworking.script'

  @initialize()

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      aeronaut: HQ.Actors.Aeronaut

    @setCallbacks
      BackToMainQuestions: (complete) =>
        # Hook back into the Reuben's main script.
        aeronaut = LOI.adventure.getCurrentThing HQ.Actors.Aeronaut
        aeronaut.listeners[0].startScript label: 'MainQuestions'

        complete()

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    return unless choicePlaceholderResponse.scriptId is HQ.Actors.Aeronaut.id()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestions'

    labels = [
      'HowToDrawChoice'
      'HowToEditInAppChoice'
      # TODO: 'HowToDownloadChoice'
      # TODO: 'HelpWithSoftwareChoice'
    ]

    choicePlaceholderResponse.addChoice @script.startNode.labels[label].next for label in labels
