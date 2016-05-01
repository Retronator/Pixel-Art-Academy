AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas.Tool extends AM.Component
  constructor: (@spriteCanvas) ->
    @mouseState =
      x: null
      y: null
      leftButton: false
      middleButton: false
      rightButton: false

  spriteData: ->
    @spriteCanvas.drawing.spriteData()

  styleClasses: ->

  activeClass: ->
    'active' if @spriteCanvas.activeTool() is @

  mouseDown: (event) ->
    switch event.which
      when 1 then @mouseState.leftButton = true
      when 2 then @mouseState.middleButton = true
      when 3 then @mouseState.rightButton = true

  mouseUp: (event) ->
    switch event.which
      when 1 then @mouseState.leftButton = false
      when 2 then @mouseState.middleButton = false
      when 3 then @mouseState.rightButton = false

  mouseMove: (event) ->
    pixelCoordinate = @spriteCanvas.mouse().pixelCoordinate()
    @mouseState.x = pixelCoordinate.x
    @mouseState.y = pixelCoordinate.y

  getIndexWithRamp: (ramp) ->
    data = @spriteCanvas.drawing.spriteData()

    # Find first index with this ramp.
    for index of data.colorMap
      if data.colorMap[index].ramp is ramp
        return parseInt index

    # No indexed color matches this ramp.
    null

  addNewIndex: (name, ramp, shade) ->
    # Find a free index.
    data = @spriteData()

    newIndex = 0
    while data.colorMap[newIndex]
      newIndex++

    Meteor.call 'colorMapSetColor', data._id, 'Sprite', newIndex, name, ramp, shade

    newIndex    

  events: ->
    super.concat
      'click .tool': @onClickTool

  onClickTool: ->
    @spriteCanvas.activeTool @
