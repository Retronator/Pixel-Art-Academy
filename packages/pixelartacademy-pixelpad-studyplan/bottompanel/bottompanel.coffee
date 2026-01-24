AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.BottomPanel extends AM.Component
  constructor: (@studyPlan) ->
    super arguments...

    @headerHeight = 15

  onCreated: ->
    super arguments...

    @contentHeight = new ReactiveField 0
    @previousContentHeight = new ReactiveField 0

    @opened = new ReactiveField false

  onRendered: ->
    super arguments...

    @$content = @$('.content')
    @_resizeObserver = new ResizeObserver =>
      @previousContentHeight @contentHeight()
      @contentHeight @$content.outerHeight()

    @_resizeObserver.observe @$content[0]

  onDestroyed: ->
    super arguments...

    @_resizeObserver?.disconnect()

  open: ->
    @opened true

  close: ->
    @opened false

  containerStyle: ->
    maxContentHeight = Math.max @contentHeight(), @previousContentHeight()

    height: "#{maxContentHeight}px"

  panelStyle: ->
    if @opened()
      bottom: "#{@contentHeight()}px"

    else
      bottom: 0

  events: ->
    super(arguments...).concat
      'click .title': @onClickTitle

  onClickTitle: (event) ->
    @opened not @opened()
