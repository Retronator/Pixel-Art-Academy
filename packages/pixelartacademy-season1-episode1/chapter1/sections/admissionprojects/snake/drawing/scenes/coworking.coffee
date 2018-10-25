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
  
  constructor: ->
    super arguments...

    # Wait for the drawing task to be completed. We do this reactively since querying wires subscribes internally.
    @completedDrawing = new ComputedField =>
      C1.Goals.Snake.Draw.completedConditions()
    ,
      true

  destroy: ->
    super arguments...

    @completedDrawing.stop()
    
  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      reuben: HQ.Actors.Reuben

    @setCallbacks
      BackToMainQuestions: (complete) =>
        # Hook back into the Reuben's main script.
        reuben = LOI.adventure.getCurrentThing HQ.Actors.Reuben
        reuben.listeners[0].startScript label: 'MainQuestions'

        complete()

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    coworking = @options.parent
    
    return unless choicePlaceholderResponse.scriptId is HQ.Actors.Reuben.id()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestions'

    if coworking.completedDrawing()
      Tracker.nonreactive =>
        # Store high score to script.
        highScore = PAA.Pico8.Cartridges.Snake.state 'highScore'
        @script.ephemeralState 'highScore', highScore

      choicePlaceholderResponse.addChoice @script.startNode.labels.CompletedDrawingChoice.next
      return
    
    labels = [
      'HowToDrawChoice'
      'HowToEditInAppChoice'
      'HowToDownloadChoice'
      'HelpWithSoftwareChoice'
    ]

    choicePlaceholderResponse.addChoice @script.startNode.labels[label].next for label in labels
