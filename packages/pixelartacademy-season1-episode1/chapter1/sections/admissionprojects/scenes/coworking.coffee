LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.AdmissionProjects.Coworking extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects.Coworking'

  @location: -> HQ.Coworking

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/admissionprojects/scenes/coworking.script'

  @initialize()

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      aeronaut: HQ.Actors.Aeronaut

    @setCallbacks
      StartProject: (complete) =>
        @ephemeralState 'startError', null

        C1.Projects.Snake.start LOI.characterId(), (error) =>
          if error
            console.error error
            @ephemeralState 'startError', error

          else
            # Start Snake section.
            C1.AdmissionProjects.Snake.state 'started', true

          complete()

  # Listener

  onCommand: (commandResponse) ->
    return unless aeronaut = LOI.adventure.getCurrentThing HQ.Actors.Aeronaut

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, aeronaut.avatar]
      action: => @startScript()
