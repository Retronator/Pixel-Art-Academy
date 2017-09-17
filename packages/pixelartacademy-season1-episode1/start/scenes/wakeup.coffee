LOI = LandsOfIllusions
Start = PixelArtAcademy.Season1.Episode1.Start
Apartment = SanFrancisco.Apartment

Vocabulary = LOI.Parser.Vocabulary

class Start.WakeUp extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Start.WakeUp'

  @location: -> Apartment.Studio

  @translations: ->
    intro: "You find yourself … nowhere. Everything is pitch black."

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter2/sections/intro/scenes/caltrain.script'

  description: ->
    @translations()?.intro unless @eyesOpened()

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/start/scenes/wakeup.script'

  constructor: ->
    super

    @eyesOpened = new ReactiveField false

  destroy: ->
    super

    @cancelHint()

  removeExits: ->
    # Don't show exits until they open their eyes.
    return if @eyesOpened()

    "#{Vocabulary.Keys.Directions.Out}": Apartment.Hallway

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
        complete()

        section = scene.options.parent
        episode = section.options.parent

        episode.showEpisodeTitle
          toBeContinued: true

        # TODO: Continue with the story.
        return

        scene.eyesOpened true
        
        # Reset the interface to show the new intro.
        LOI.adventure.interface.resetInterface?()

        # Start the welcome script.
        @options.listener.startScript label: 'Welcome'

      StartDay: (complete) =>
        # TODO: Show day 1 start.

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
