LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.GalleryWest'

  @location: ->
    HQ.GalleryWest

  @intro: -> """
    You enter a big gallery space that is holding a gathering.
    You recognize some people from the HQ, others seem to be visitors like yourself.
  """

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/mixer/scenes/gallerywest.script'

  @initialize()

  things: -> [
    HQ.Actors.Shelley
    @constructor.Retro
    HQ.Actors.Alexandra
    HQ.Actors.Reuben
    C1.Mixer.Marker
    C1.Mixer.Stickers
  ]
    
  # Script

  initializeScript: ->
    @setCurrentThings
      retro: HQ.Actors.Retro
      alexandra: HQ.Actors.Alexandra
      shelley: HQ.Actors.Shelley
      reuben: HQ.Actors.Reuben

    # TODO: Animate characters in callbacks.
    @setCallbacks
      IceBreakerStart: (complete) =>
        console.log "Animating characters to the middle."
        complete()

      HobbyProfessionStart: (complete) =>
        console.log "Animating characters based on hobby/profession."
        complete()

      HobbyProfessionEnd: (complete) =>
        answers = @state 'answers'
        console.log "Animating character to location", answers[0]
        console.log "Animating any remaining characters based on hobby/profession."
        complete()

  # Listener

  onEnter: (enterResponse) ->
    # Retro should talk when at location.
    @_retroTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless retro = LOI.adventure.getCurrentThing HQ.Actors.Retro
      return unless retro.ready()
      computation.stop()

      @script.setThings {retro}

      @startScript label: 'RetroIntro'

    # Player should be in the mixer context when they have a name tag.
    @_enterContextAutorun = @autorun (computation) =>
      return if LOI.adventure.currentContext() instanceof C1.Mixer.Context
      return unless LOI.adventure.getCurrentInventoryThing C1.Mixer.NameTag
      
      LOI.adventure.enterContext C1.Mixer.Context

      # Start the mixer script at the latest checkpoint.
      checkpoints = [
        'MixerStart'
        'IceBreakerStart'
        'HobbyProfessionWriteStart'
      ]

      for checkpoint, index in checkpoints
        # Start at this checkpoint if we haven't reached the next one yet.
        nextCheckpoint = checkpoints[index + 1]

        unless nextCheckpoint and @script.state nextCheckpoint
          @startScript label: checkpoint
          return

  cleanup: ->
    @_retroTalksAutorun?.stop()
    @_enterContextAutorun?.stop()

  onCommand: (commandResponse) ->
    return unless alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra
    return unless retro = LOI.adventure.getCurrentThing HQ.Actors.Retro
    return unless shelley = LOI.adventure.getCurrentThing HQ.Actors.Shelley
    return unless reuben = LOI.adventure.getCurrentThing HQ.Actors.Reuben

    return unless marker = LOI.adventure.getCurrentThing C1.Mixer.Marker
    return unless stickers = LOI.adventure.getCurrentThing C1.Mixer.Stickers

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
      action: => @startScript label: 'TalkToAlexandra'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, retro]
      action: => @startScript label: 'TalkToRetro'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, shelley]
      action: => @startScript label: 'TalkToShelley'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, reuben]
      action: => @startScript label: 'TalkToReuben'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Get, marker]
      action: =>
        marker.state 'inInventory', true
        true

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Get, stickers]
      action: =>
        stickers.state 'inInventory', true
        true
