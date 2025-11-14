AE = Artificial.Everywhere
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.RealisticDrawing
  @debug = false
  
  @durations = [
    60
    45
    30
    20
    10
  ]
  
  @thingsToDraw = ["airplane","alarm clock","ant","apple","axe","banana","bat","bear","bee","bench","bicycle","bread",
    "butterfly","camel","candle","cannon","car","castle","cat","chair","church","couch","cow","crab","cup","dog",
    "dolphin","door","duck","elephant","eyeglasses","fan","fish","flower","frog","giraffe","guitar","hamburger",
    "hammer","harp","hat","hedgehog","helicopter","horse","hot air balloon","hourglass","kangaroo","knife","lion",
    "lobster","mouse","mushroom","owl","parrot","pear","penguin","piano","pickup truck","pig","pineapple","pizza",
    "rabbit","raccoon","rhinoceros","rifle","sailboat","saw","saxophone","scissors","scorpion","turtle","shark",
    "sheep","shoe","skyscraper","snail","snake","spider","spoon","squirrel","strawberry","swan","sword","table",
    "teapot","teddy bear","tiger","tree","trumpet","umbrella","violin","windmill","bottle","zebra"]
  
  constructor: (@drawQuickly) ->
    @canvasText = new ReactiveField ""
    @score = new ReactiveField
      symbolic: 0
      realistic: 0
    
    @timer = new ReactiveField null
    @canvas = new ReactiveField null

    @completedDurationsCount = new ReactiveField 0
    @durationIndex = new ReactiveField 0
    @thingToDraw = 'airplane'
  
  destroy: ->
    @_startTimerAutorun?.stop()
    @_endTimerAutorun?.stop()
    @_evaluateAutorun?.stop()
  
  setThingToDraw: (@thingToDraw) ->
  
  start: ->
    @canvas @drawQuickly.os.interface.allChildComponentsOfType(DrawQuickly.Interface.Game.Draw.Canvas)[0]

    @durationIndex 0
    @startDuration()
  
  startDuration: ->
    @canvasText ""
    @score
      symbolic: 0
      realistic: 0
    
    durationIndex = @durationIndex()
    duration = @constructor.durations[durationIndex]
    timer = new DrawQuickly.Timer duration
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
    
    # Evaluate what is drawn.
    @_evaluateAutorun = @drawQuickly.autorun (computation) =>
      canvas = @canvas()

      unless inputData = canvas.classificationInputData()
        @score
          symbolic: 0
          realistic: 0
        
        return
      
      Tracker.nonreactive =>
        classificationPromises = for classifierType, classifier of @drawQuickly.classifiers
          do (classifierType, classifier) =>
            new Promise (resolve, reject) =>
              labelProbabilities = await classifier.classify inputData
              resolve {classifierType, labelProbabilities}
        
        classifierResults = await Promise.all classificationPromises
        
        # Add together the results from all classifiers.
        score = {}
        
        for classifierResult in classifierResults
          for labelProbability in classifierResult.labelProbabilities when labelProbability.label is @thingToDraw
            score[classifierResult.classifierType] = labelProbability.probability
        
        @score score
        
  endDuration: ->
    @_startTimerAutorun.stop()
    @_endTimerAutorun.stop()

    Meteor.setTimeout =>
      # Get scores after the evaluation had time to complete one final time.
      @_evaluateAutorun.stop()
      
      drawingId = DrawQuickly.Drawing.save @canvas().getPlainStrokes()
      
      durationIndex = @durationIndex()
    
      realisticDrawingData = @drawQuickly.state 'realisticDrawing'
      realisticDrawingData ?= things: {}
      realisticDrawingData.things[@thingToDraw] ?= durations: []
      realisticDrawingData.things[@thingToDraw].durations[durationIndex] =
        drawingId: drawingId
        score: @score()
        
      @drawQuickly.state 'realisticDrawing', realisticDrawingData

      # Move forward.
      durationIndex++
      
      if durationIndex is @constructor.durations.length
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
