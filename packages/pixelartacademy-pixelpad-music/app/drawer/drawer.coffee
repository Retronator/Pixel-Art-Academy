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
      caseOpen: AEc.ValueTypes.Trigger
      caseClose: AEc.ValueTypes.Trigger
      
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
      @audio.drawerOpen()
    ,
      500
    
  onDestroyed: ->
    super arguments...
    
    @tapesLocation.destroy()

  deselectTape: ->
    AB.Router.changeParameter 'parameter3', null

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
      'mouseenter .tape': @onMouseEnterTape
      'mouseleave .tape': @onMouseLeaveTape

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
      AB.Router.changeParameter 'parameter3', null
      await _.waitForSeconds 0.2
      
    AB.Router.changeParameter 'parameter3', tape.slug

    # Start tape on side A at the beginning.
    PAA.PixelPad.Systems.Music.state 'sideIndex', 0
    PAA.PixelPad.Systems.Music.state 'trackIndex', 0
    PAA.PixelPad.Systems.Music.state 'currentTime', 0
  
  onMouseEnterTape: (event) ->
    tape = @currentData()
    
    @hoveredTape tape
  
  onMouseLeaveTape: (event) ->
    @hoveredTape null
