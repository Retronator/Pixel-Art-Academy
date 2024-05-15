AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelPad.Apps.Music extends PAA.PixelPad.App
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Music'
  @url: -> 'music'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Music"
  @description: ->
    "
      Play cassette tapes for extra music!
    "

  @initialize()

  constructor: ->
    super arguments...

    @resizable false

    @drawer = new ReactiveField null
    @player = new ReactiveField null

    @tape = new ReactiveField null

  onCreated: ->
    super arguments...
    
    @system = new ComputedField =>
      return unless LOI.adventure.ready()
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless musicSystem = _.find pixelPad.os.currentSystems(), (system) => system instanceof PAA.PixelPad.Systems.Music
      return unless musicSystem.isCreated()
      musicSystem

    @drawer new @constructor.Drawer @
    @player new @constructor.Player @
    
    # Subscribe to all tapes, built-in and from the server.
    PAA.Music.Tape.all.subscribeContent @
    PAA.Music.Tape.all.subscribe @
    
    # Change PixelPad size.
    @autorun (computation) =>
      if @tape()
        @setFixedPixelPadSize 320, 157

      else
        @setFixedPixelPadSize 380, 300
        
    # Set parameters if music system has an active tape.
    @autorun (computation) =>
      return unless tapeId = PAA.PixelPad.Systems.Music.state 'tapeId'
      return unless tape = PAA.Music.Tape.documents.findOne tapeId
      
      AB.Router.changeParameters
        parameter3: tape.slug
        parameter4: 'play'
    
    # Set/unset tape if in play.
    @autorun (computation) =>
      tapeParameter = AB.Router.getParameter 'parameter3'
      playParameter = AB.Router.getParameter 'parameter4'
      
      if tapeParameter and playParameter
        @tape @drawer().selectedTape()
      
      else
        Tracker.nonreactive =>
          # Turn off the player and deselect the tape when returning from play.
          if @tape()
            # Wait for the eject animation.
            Meteor.setTimeout =>
              @tape null
              @drawer().deselectTape()
            ,
              1000
  
  inGameMusicMode: -> LM.Interface.InGameMusicMode.Direct
  
  tapeActiveClass: ->
    'tape-active' if @tape()
    
  onBackButton: ->
    # Fully close the app if going back from the player.
    return unless AB.Router.getParameter 'parameter4'
    
    AB.Router.changeParameters
      parameter2: null
      parameter3: null
      parameter4: null
    
    # Inform that we've handled the back button.
    true
