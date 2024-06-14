AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Music.Drawer extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Music.Drawer'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      drawerOpen: AEc.ValueTypes.Trigger
      casePickUp: AEc.ValueTypes.Trigger
      casePutDown: AEc.ValueTypes.Trigger
      caseSlideUp:
        valueType: AEc.ValueTypes.Trigger
        throttle: 200
      caseSlideDown:
        valueType: AEc.ValueTypes.Trigger
        throttle: 200
      selectedCasePan:
        valueType: AEc.ValueTypes.Number
      deselectedCasePan:
        valueType: AEc.ValueTypes.Number
      slideUpCasePan:
        valueType: AEc.ValueTypes.Number
      slideDownCasePan:
        valueType: AEc.ValueTypes.Number
      
  constructor: (@music) ->
    super arguments...

    @opened = new ReactiveField false
    @hoveredTape = new ReactiveField null

  onCreated: ->
    super arguments...

    @tapesLocation = new PAA.Music.Tapes

    @tapesSituation = new ComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: @tapesLocation

      return unless options.timelineId

      new LOI.Adventure.Situation options

    @tapes = new ComputedField =>
      return unless tapesSituation = @tapesSituation()

      tapeSelectors = tapesSituation.things()

      tapes = for tapeSelector in tapeSelectors
        PAA.Music.Tape.documents.findOne tapeSelector
        
      _.without tapes, undefined

  onRendered: ->
    super arguments...

    # Open the drawer on app launch.
    Meteor.setTimeout =>
      @opened true
      
      # Don't play the sound if we're focused on the player.
      @audio.drawerOpen() unless PAA.PixelPad.Systems.Music.state 'tapeId'
    ,
      500
    
  onDestroyed: ->
    super arguments...
    
    @tapesLocation.destroy()
    
  selectTape: (tape) ->
    AB.Router.changeParameter 'parameter3', tape.slug
    @audio.casePickUp()

  deselectTape: ->
    AB.Router.changeParameter 'parameter3', null
    @audio.deselectedCasePan @audio.selectedCasePan.value()
    @audio.casePutDown()

  openedClass: ->
    'opened' if @opened()

  tapeSelectedClass: ->
    tape = @currentData()

    'selected' if tape._id is @music.selectedTape()?._id
  
  tapeHoveredClass: ->
    tape = @currentData()
  
    'hovered' if tape._id is @hoveredTape()?._id
  
  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .tape': @onClickTape
      'pointerenter .tape': @onPointerEnterTape
      'pointerleave .tape': @onPointerLeaveTape

  onClick: (event) ->
    return if @music.loadedTape()
    return unless @music.selectedTape()

    $target = $(event.target)
    return if $target.closest('.selected-tape').length
    return if $target.closest('.tape').length

    @deselectTape()

  onClickTape: (event) ->
    tape = @currentData()
    
    if AB.Router.getParameter 'parameter3'
      @deselectTape()
      await _.waitForSeconds 0.2
      
    @audio.selectedCasePan AEc.getPanForElement event.target
    @selectTape tape

    # Start tape on side A at the beginning.
    PAA.PixelPad.Systems.Music.state 'sideIndex', 0
    PAA.PixelPad.Systems.Music.state 'trackIndex', 0
    PAA.PixelPad.Systems.Music.state 'currentTime', 0
  
  onPointerEnterTape: (event) ->
    tape = @currentData()
    
    @audio.slideUpCasePan AEc.getPanForElement event.target
    
    @hoveredTape tape
    @audio.caseSlideUp()
  
  onPointerLeaveTape: (event) ->
    @hoveredTape null
    
    @audio.slideDownCasePan @audio.slideUpCasePan.value()
    @audio.caseSlideDown()
