AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Array extends C3.Design.Terminal.Properties.Property
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Array'

  onCreated: ->
    super arguments...

    @showTypes = new ReactiveField false
    @draggingPart = new ReactiveField null
    @draggingPartIndex = new ReactiveField null
    @draggingVisiblyActive = new ReactiveField false

  parts: ->
    property = @data()
    parts = property.parts()

    draggingPart = @draggingPart()
    draggingPartIndex = @draggingPartIndex()

    return parts unless draggingPart and draggingPartIndex?

    # Place dragging part to requested index.
    parts = _.without parts, draggingPart
    parts.splice draggingPartIndex, 0, draggingPart

    parts
  
  avatarPartPreviewOptions: ->
    rendererOptions:
      renderingSides: [LOI.Engine.RenderingSides.Keys.Front]

  draggingClass: ->
    'dragging' if @draggingVisiblyActive()

  draggingPartClass: ->
    part = @currentData()

    'dragging-part' if @draggingPart() is part

  events: ->
    super(arguments...).concat
      'mousedown .parts .part': @onMouseDownPart
      'mouseenter .parts .part': @onMouseEnterPart
      'click .parts .part': @onClickPart
      'click .new-array-part-button': @onClickNewArrayPartButton
      'click .new-array-part-type-button': @onClickNewArrayPartTypeButton

  onMouseDownPart: (event) ->
    part = @currentData()

    @draggingPart part
    @draggingPartIndex null

    Meteor.clearTimeout @_draggingActiveTimeout

    @_draggingActiveTimeout = Meteor.setTimeout =>
      @draggingVisiblyActive true
    ,
      200

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.sanfrancisco-c3-design-terminal-properties-array', =>
      $(document).off '.sanfrancisco-c3-design-terminal-properties-array'

      draggingPartIndex = @draggingPartIndex()
      property = @data()
      property.reorderPart part, draggingPartIndex if draggingPartIndex?

      @draggingPart null
      @draggingPartIndex null

      Meteor.clearTimeout @_draggingActiveTimeout

      @_draggingActiveTimeout = Meteor.setTimeout =>
        @draggingVisiblyActive false

  onMouseEnterPart: (event) ->
    enteredPart = @currentData()
    return unless @draggingPart()

    parts = @parts()
    enteredPartIndex = parts.indexOf enteredPart

    @draggingPartIndex enteredPartIndex

  onClickPart: (event) ->
    part = @currentData()

    return if @draggingVisiblyActive()

    terminal = @ancestorComponentOfType C3.Design.Terminal
    terminal.screens.avatarPart.pushPart part

  onClickNewArrayPartButton: (event) ->
    property = @data()

    if property.options.type
      @_goToNewPart property.options.type
      
    else
      @showTypes not @showTypes()

  onClickNewArrayPartTypeButton: (event) ->
    type = @currentData()
    @_goToNewPart type
    
  _goToNewPart: (type) ->
    property = @data()
    part = property.newPart type

    terminal = @ancestorComponentOfType C3.Design.Terminal
    terminal.screens.avatarPart.pushPart part
