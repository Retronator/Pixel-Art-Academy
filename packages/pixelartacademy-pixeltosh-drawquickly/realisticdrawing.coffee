AE = Artificial.Everywhere
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.RealisticDrawing
  @debug = false
  
  @ComplexityProperties =
    Simple: 'simple'
    Medium: 'medium'
    Complex: 'complex'
  
  @durationsPerComplexity =
    simple: [
      20
      10
      5
    ]
    medium: [
      40
      20
      10
    ]
    complex: [
      60
      30
      15
    ]
  
  @getDrawnThings: ->
    return [] unless realisticDrawingData = DrawQuickly.state 'realisticDrawing'
    return [] unless things = realisticDrawingData.things
    
    _.keys things
    
  @getDrawnThingsForComplexity: (complexity) ->
    drawnThings = @getDrawnThings()
    allThings = @thingsByComplexity[complexity]
    _.intersection drawnThings, allThings
  
  constructor: (@drawQuickly) ->
    @canvasText = new ReactiveField ""
    
    @timer = new ReactiveField null
    @canvas = new ReactiveField null

    @durationIndex = new ReactiveField 0

    @complexity = @constructor.ComplexityProperties.Simple
    @thingToDraw = ''
  
  destroy: ->
    @stop()
    
  stop: ->
    @_startTimerAutorun?.stop()
    @_endTimerAutorun?.stop()
    
  setComplexity: (@complexity) ->
  
  setThingToDraw: (@thingToDraw) ->
  
  start: ->
    @canvas @drawQuickly.os.interface.allChildComponentsOfType(DrawQuickly.Interface.Game.Draw.Canvas)[0]

    @durationIndex 0
    @startDuration()
  
  startDuration: ->
    @canvasText ""
    
    durationIndex = @durationIndex()
    duration = @constructor.durationsPerComplexity[@complexity][durationIndex]
    timer = new DrawQuickly.Timer @drawQuickly, duration
    @timer timer
    
    canvas = @canvas()
    canvas.reset()
    
    # Start timer when the player starts drawing.
    @_startTimerAutorun = @drawQuickly.autorun (computation) =>
      return unless canvas.drawingStarted()
      computation.stop()
      timer.start()
      
    # End duration when the timer runs out.
    @_endTimerAutorun = @drawQuickly.autorun (computation) =>
      return if timer.running()
      return if timer.time()
      computation.stop()
      
      @canvas().endDrawing()
      @canvasText "Time's up!"
      @endDuration()
        
  endDuration: ->
    @stop()

    drawingId = DrawQuickly.Drawing.save @canvas().getPlainStrokes()
    durationIndex = @durationIndex()
    
    realisticDrawingData = @drawQuickly.state 'realisticDrawing'
    realisticDrawingData ?= things: {}
    realisticDrawingData.things[@thingToDraw] ?= durations: []
    realisticDrawingData.things[@thingToDraw].durations[durationIndex] = {drawingId}
    
    @drawQuickly.state 'realisticDrawing', realisticDrawingData
    
    Meteor.setTimeout =>
      # Move forward.
      durationIndex++
      
      if durationIndex is @constructor.durationsPerComplexity[@complexity].length
        return unless gameView = @drawQuickly.os.interface.getView DrawQuickly.Interface.Game
        gameView.showResults()
        
      else
        # Switch to the next duration.
        @durationIndex durationIndex
        @startDuration()
    ,
      2000

  update: (gameTime) ->
    return unless timer = @timer()
    
    timer.update gameTime
