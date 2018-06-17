LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.AdmissionProjects.Snake.Intro.Coworking extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects.Snake.Intro.Coworking'

  @location: -> HQ.Coworking

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/admissionprojects/snake/intro/scenes/coworking.script'

  @initialize()

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      aeronaut: HQ.Actors.Aeronaut

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    return unless choicePlaceholderResponse.scriptId is HQ.Actors.Aeronaut.id()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestions'

    # Prerequisite is to ask what Reuben's working on.
    return unless Retronator.HQ.Actors.Aeronaut.Listener.Script.state 'UpTo'

    # Store in state if the character has the Snake project added to the Study Plan.
    hasSnakeGoal = PAA.PixelBoy.Apps.StudyPlan.hasGoal C1.Goals.Snake
    Tracker.nonreactive => @script.ephemeralState 'hasSnakeGoal', hasSnakeGoal

    # Store in state if the character has the PICO-8 app.
    pixelBoy = LOI.adventure.getCurrentThing PAA.PixelBoy
    hasPico8 = PAA.PixelBoy.Apps.Pico8 in pixelBoy.os.currentAppsSituation().things()
    Tracker.nonreactive => @script.ephemeralState 'hasPico8', hasPico8

    # If the player has seen PICO-8 questions, allow to ask them again until PICO-8 is acquired.
    if @script.state('Pico8Questions') and not hasPico8
      choicePlaceholderResponse.addChoice @script.startNode.labels.Pico8Choice.next

    # If player has the snake goal and didn't before, let them report it.
    else if @script.state('AddToStudyPlan') and hasSnakeGoal
      console.log "adding"
      choicePlaceholderResponse.addChoice @script.startNode.labels.AddedSnakeGoal.next

    else
      # Show the offer to help.
      choicePlaceholderResponse.addChoice @script.startNode.labels.OfferHelp.next

