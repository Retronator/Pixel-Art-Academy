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
      tapeSelect: AEc.ValueTypes.Trigger
      
  constructor: (@music) ->
    super arguments...

    @opened = new ReactiveField false
    @selectedTape = new ReactiveField null

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
      
    # Select tape based on URL parameter.
    @autorun (computation) =>
      if tapeSlug = AB.Router.getParameter 'parameter3'
        @selectedTape PAA.Music.Tape.documents.findOne slug: tapeSlug
      
      else
        @audio.caseClose() if Tracker.nonreactive => @selectedTape()
        @selectedTape null

  onRendered: ->
    super arguments...

    # Open the drawer on app launch.
    Meteor.setTimeout =>
      @opened true
      @audio.drawerOpen()
    ,
      500

  deselectTape: ->
    AB.Router.changeParameter 'parameter3', null

  openedClass: ->
    'opened' if @opened()

  coveredClass: ->
    'covered' if @music.tape()

  activeClass: ->
    'active' if @selectedTape()

  selectedClass: ->
    tape = @currentData()

    'selected' if tape._id is @selectedTape()?._id

  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .tape': @onClickTape
      'click .selected-tape': @onClickSelectedTape

  onClick: (event) ->
    return if @music.tape()
    return unless @selectedTape()

    $target = $(event.target)
    return if $target.closest('.selected-tape').length

    @deselectTape()

  onClickTape: (event) ->
    tape = @currentData()
    AB.Router.changeParameter 'parameter3', tape.slug
    
    @audio.caseOpen()
  
  onClickSelectedTape: (event) ->
    AB.Router.changeParameter 'parameter4', 'play'
    @music.system().setTape @selectedTape()
    
    @audio.tapeSelect()
