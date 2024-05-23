AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
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
  
  @TopPositions =
    Drawer: 0
    Player: 300
    
  @CassettePositions =
    Top:
      Case: 0
      OutsideCase: -30
      OutsidePlayer: -162
      Player: -255
    Left:
      Case: 0
      Player: -78
  
  @spoolRotationSpeedLeft = 20 # frames / second
  @spoolRotationSpeedRight = 15 # frames / second

  constructor: ->
    super arguments...

    @resizable false

    @drawer = new ReactiveField null
    @player = new ReactiveField null

  onCreated: ->
    super arguments...
    
    @app = @ancestorComponentOfType AB.App
    @app.addComponent @
    
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
    
    @selectedTape = new ReactiveField null
    
    # Displayed tape is the same as selected, except it doesn't revert to null to allow for styled animations.
    @displayedTape = new ReactiveField null
    
    @loadedTape = new ComputedField =>
      return unless tapeId = PAA.PixelPad.Systems.Music.state 'tapeId'
      PAA.Music.Tape.documents.findOne tapeId
    
    # Change PixelPad size.
    @pixelPadSizeToPlayer = new ReactiveField PAA.PixelPad.Systems.Music.state 'tapeId'
    
    @autorun (computation) =>
      if @pixelPadSizeToPlayer()
        @setFixedPixelPadSize 330, 204

      else
        @setFixedPixelPadSize 380, 260
        
    # Set parameters if music system has an active tape.
    @autorun (computation) =>
      return unless tapeId = PAA.PixelPad.Systems.Music.state 'tapeId'
      return unless tape = PAA.Music.Tape.documents.findOne tapeId
      
      AB.Router.changeParameters
        parameter3: tape.slug
        parameter4: 'play'
        
      @loadedTape tape
    
    # Select tape based on URL parameter.
    @autorun (computation) =>
      tapeParameter = AB.Router.getParameter 'parameter3'
      
      if tapeParameter
        tape = PAA.Music.Tape.documents.findOne slug: tapeParameter
        return unless tape

        @selectedTape tape
        @displayedTape tape
        
      else
        @selectedTape null
    
    @animating = new ReactiveField null
    
  onRendered: ->
    super arguments...
    
    @$origin = @$ '.origin'
    @$case = @$ '.selected-tape .case'
    @$cassette = @$ '.selected-tape .cassette'
    @$cassetteSpoolLeft = @$ '.selected-tape .cassette .spool.left'
    @$cassetteSpoolRight = @$ '.selected-tape .cassette .spool.right'
    
    @_resetSpoolRotation()
    
    # If we have a tape inserted, start at the player.
    @autorun (computation) =>
      return unless AMu.Document.Persistence.profileReady()
      computation.stop()
      
      if PAA.PixelPad.Systems.Music.state 'tapeId'
        @$origin.css top: "#{@constructor.TopPositions.Player}rem"
        
        @$cassette.css
          left: "#{@constructor.CassettePositions.Left.Player}rem"
          top: "#{@constructor.CassettePositions.Top.Player}rem"
        
        @$case.addClass 'open'
        
      else
        # We're not at the player, animate the intro.
        @$origin.css top: "#{@constructor.TopPositions.Drawer}rem"
        
        @$cassette.css
          left: "#{@constructor.CassettePositions.Left.Case}rem"
          top: "#{@constructor.CassettePositions.Top.Case}rem"
          
  onDestroyed: ->
    super arguments...
    
    @app.removeComponent @
    
  _resetSpoolRotation: ->
    @spoolRotationLeft = 0
    @spoolFrameIndexLeft = 0
    @spoolRotationRight = 3
    @spoolFrameIndexRight = 3
    @_updateSpoolFrames()
    
  _updateSpoolFrames: ->
    @_updateSpoolFrame @$cassetteSpoolLeft, @spoolFrameIndexLeft
    @_updateSpoolFrame @$cassetteSpoolRight, @spoolFrameIndexRight
    
  _updateSpoolFrame: ($spool, frameIndex) ->
    $spool.css
      backgroundPositionX: "#{frameIndex * 14}rem"
      
  loadSelectedTape: ->
    @animating true
    
    @_resetSpoolRotation()
    
    @$case.addClass 'open'
    
    # Move the cassette tape outside the case, in front of the player, and slide it into the tray.
    
    @$cassette.velocity
      top: ["#{@constructor.CassettePositions.Top.OutsideCase}rem", 'ease-in', "#{@constructor.CassettePositions.Top.Case}rem"]
    ,
      duration: 200
      delay: 200
    
    @$cassette.velocity
      left: ["#{@constructor.CassettePositions.Left.Player}rem", 'ease-in-out', "#{@constructor.CassettePositions.Left.Drawer}rem"]
      top: ["#{@constructor.CassettePositions.Top.OutsidePlayer}rem", 'linear', "#{@constructor.CassettePositions.Top.OutsideCase}rem"]
    ,
      duration: 800
      
    @$cassette.velocity
      top: ["#{@constructor.CassettePositions.Top.Player}rem", 'ease-out', "#{@constructor.CassettePositions.Top.OutsidePlayer}rem"]
    ,
      duration: 500
    
    # Move camera from drawer to player.
    
    @$origin.velocity
      top: "#{@constructor.TopPositions.Player}rem"
    ,
      duration: 1000
      delay: 300
      easing: 'ease-in-out'
      
    # During the transition, resize pixelPad.
    
    await _.waitForSeconds 0.4
    
    @pixelPadSizeToPlayer true
    
    await _.waitForSeconds 1.5
    
    # Set the tape to complete the animation.
    
    AB.Router.changeParameter 'parameter4', 'play'
    @system().setTape @selectedTape()
    
    @animating false
    
  unloadTape: ->
    @animating true
    
    # Remove the tape, which opens the tray.
    
    @system().setTape null
    
    @$case.addClass 'unloading'
    
    # Move cassette tape out of the player.
    
    @$cassette.velocity
      top: "#{@constructor.CassettePositions.Top.OutsidePlayer}rem"
    ,
      duration: 500
      delay: 200
      
    # Move camera from player to drawer.
    
    @$origin.velocity
      top: "#{@constructor.TopPositions.Drawer}rem"
    ,
      duration: 1000
      delay: 400
    
    # At the start of the transition, resize pixelPad.
    
    await _.waitForSeconds 0.4

    @pixelPadSizeToPlayer false
    
    await _.waitForSeconds 1

    # Deselect the tape and reset CSS.
    
    AB.Router.changeParameters
      parameter3: null
      parameter4: null
    
    await _.waitForSeconds 0.2
    
    @$case.removeClass 'open'

    @$cassette.css
      left: "#{@constructor.CassettePositions.Left.Case}rem"
      top: "#{@constructor.CassettePositions.Top.Case}rem"
      
    @$case.removeClass 'unloading'
  
    @animating false
  
  inGameMusicMode: -> LM.Interface.InGameMusicMode.Direct
  
  selectedTapeActiveClass: ->
    'active' if @selectedTape()

  selectedTapeLoadedClass: ->
    'loaded' if @loadedTape()
  
  cassetteSideLetter: ->
    if (PAA.PixelPad.Systems.Music.state('sideIndex') or 0) is 0 then 'A' else 'B'
  
  cassetteLabel: ->
    return unless tape = tape = @displayedTape()

    if tape.title
      title = tape.title
      
    else
      title = tape.sides[PAA.PixelPad.Systems.Music.state('sideIndex') or 0].title
    
    "#{tape.artist} - #{title}"
    
  onBackButton: ->
    # Fully close the app if going back from the player.
    return unless AB.Router.getParameter 'parameter4'
    
    AB.Router.changeParameters
      parameter2: null
      parameter3: null
      parameter4: null
    
    # Inform that we've handled the back button.
    true
  
  update: (appTime) ->
    return unless LOI.adventure.music.enabled()
    return unless PAA.PixelPad.Systems.Music.state 'playing'
    
    @spoolRotationLeft += @constructor.spoolRotationSpeedLeft * appTime.elapsedAppTime
    newSpoolFrameIndexLeft = Math.floor(@spoolRotationLeft) % 6
    unless newSpoolFrameIndexLeft is @spoolFrameIndexLeft
      @spoolFrameIndexLeft = newSpoolFrameIndexLeft
      @_updateSpoolFrame @$cassetteSpoolLeft, @spoolFrameIndexLeft
    
    @spoolRotationRight += @constructor.spoolRotationSpeedRight * appTime.elapsedAppTime
    newSpoolFrameIndexRight = Math.floor(@spoolRotationRight) % 6
    unless newSpoolFrameIndexRight is @spoolFrameIndexRight
      @spoolFrameIndexRight = newSpoolFrameIndexRight
      @_updateSpoolFrame @$cassetteSpoolRight, @spoolFrameIndexRight
    
  events: ->
    super(arguments...).concat
      'click .selected-tape': @onClickSelectedTape
  
  onClickSelectedTape: (event) ->
    return if @animating()
    return if @loadedTape()
    
    @loadSelectedTape()
