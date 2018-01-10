LOI = LandsOfIllusions
Start = PixelArtAcademy.Season1.Episode1.Start
Apartment = SanFrancisco.Apartment

Vocabulary = LOI.Parser.Vocabulary

class Start.WakeUp extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Start.WakeUp'

  @location: -> Apartment.Studio

  @translations: ->
    intro: "You find yourself … nowhere. Everything is pitch black."

  description: ->
    @translations()?.intro

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/start/scenes/wakeup.script'

  destroy: ->
    super

    @cancelHint()

  removeExits: ->
    # Don't show exits until they open their eyes.
    "#{Vocabulary.Keys.Directions.Out}": Apartment.Hallway

  removeThings: ->
    # Don't show things until they open their eyes.
    [
      LOI.character()
      Apartment.Studio.Computer
    ]

  giveHint: (delay) ->
    # Cancel any previous timeout.
    @cancelHint()

    # Give a hint after the delay.
    @_delayedHintTimeout = Meteor.setTimeout =>
      listener = @listeners[0]

      @_hintIndex = Math.min (@_hintIndex or 0) + 1, 3
      listener.startScript label: "Try#{@_hintIndex}"

      # If we haven't displayed all three hints, give another hint after 10 seconds.
      @giveHint 10000 if @_hintIndex < 3
    ,
      delay

  cancelHint: ->
    Meteor.clearTimeout @_delayedHintTimeout
    
  # Script
  
  initializeScript: ->
    scene = @options.parent

    @setCallbacks
      OpenEyes: (complete) =>
        section = scene.options.parent
        episode = section.options.parent

        episode.showEpisodeTitle
          onActivated: =>
            # Don't finish unless the player has access.
            unless episode.meetsAccessRequirement()
              complete()
              return

            scene.state 'finished', true

            # Continue to the Chapter 1 intro script.
            Tracker.autorun (computation) =>
              return unless introStudioScene = LOI.adventure.getCurrentThing PixelArtAcademy.Season1.Episode1.Chapter1.Intro.Studio
              return unless introStudioScene.ready()
              computation.stop()

              introStudioScene.listeners[0].startScript()

              # Reset the interface to start again from the new intro.
              LOI.adventure.interface.resetInterface?()

              complete()

  # Listener

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Show the first hint after 10 seconds.
    scene.giveHint 10000

  onCommand: (commandResponse) ->
    scene = @options.parent

    # Player is trying to do something. We should show a hint unless the command is wake up or talk to character.
    correctCommand = false

    # Delay giving a hint so we can see if the command was correct.
    Meteor.setTimeout =>
      return if correctCommand

      scene.giveHint 0

    wakeUpAction = =>
      correctCommand = true
      scene.cancelHint()

      @startScript label: 'WakeUp'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, LOI.character().avatar]
      action: wakeUpAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.WakeUp]
      action: wakeUpAction
