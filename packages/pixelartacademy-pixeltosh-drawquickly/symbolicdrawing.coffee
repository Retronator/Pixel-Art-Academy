AE = Artificial.Everywhere
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.SymbolicDrawing
  @debug = false
  
  @difficultyFactors =
    easy: 0
    medium: 0
    hard: 1
    
  @timePerDifficulty =
    easy:
      easy: 90
      medium: 60
      hard: 30
    medium:
      easy: 135
      medium: 90
      hard: 45
    hard:
      easy: 180
      medium: 120
      hard: 60
  
  constructor: (@drawQuickly) ->
    @canvasText = new ReactiveField ""
    @pixeltoshClass = new ReactiveField ''
    @guessesText = new ReactiveField ""
    
    @timer = new ReactiveField null
    @canvas = new ReactiveField null
    
    @thingsToDraw = new ReactiveField []
    @thingsDrawn = new ReactiveField []
    @thingsLeftToDraw = new AE.LiveComputedField => _.difference @thingsToDraw(), @thingsDrawn()
    
    @difficulty = 'easy'
    @time = 120
  
  destroy: ->
    @thingsLeftToDraw.stop()
    @end()
  
  setDifficulty: (@difficulty) ->
  
  setTime: (@time) ->
    
  start: ->
    @canvasText ""
    @pixeltoshClass ''
    @guessesText ""
    
    timer = new DrawQuickly.Timer @time
    timer.start()
    @timer timer
    
    @canvas @drawQuickly.os.interface.allChildComponentsOfType(DrawQuickly.Interface.Game.Draw.Canvas)[0]
      
    # End game when the timer runs out.
    @_endTimerAutorun = @drawQuickly.autorun (computation) =>
      return if @timer().running()
      return if @timer().time()
      computation.stop()
      
      @canvas().endDrawing()
      @canvasText "Game over"
      @end()
    
    # Choose things to draw.
    difficultyFactor = @constructor.difficultyFactors[@difficulty]
    
    @thingsToDraw @_chooseThingsToDraw @constructor.thingsByDifficulty[@difficulty]
    @thingsDrawn []

    @drawings = {}
    
    # Evaluate what is drawn.
    @_evaluateAutorun = @drawQuickly.autorun (computation) =>
      canvas = @canvas()

      unless inputData = canvas.classificationInputData()
        @pixeltoshClass ''
        @guessesText ""
        return
      
      Tracker.nonreactive =>
        classificationPromises = for classifierType, classifier of @drawQuickly.classifiers
          do (classifierType, classifier) =>
            new Promise (resolve, reject) =>
              labelProbabilities = await classifier.classify inputData
              resolve {classifierType, labelProbabilities}
        
        classifierResults = await Promise.all classificationPromises
        
        # Add together the results from all classifiers.
        combinedLabelProbabilities = {}
        for label in PAA.Pixeltosh.Programs.DrawQuickly.Classifier.labels
          combinedLabelProbabilities[label] =
            label: label
        
        for classifierResult in classifierResults
          for labelProbability in classifierResult.labelProbabilities
            combinedLabelProbability = combinedLabelProbabilities[labelProbability.label]
            combinedLabelProbability[classifierResult.classifierType] = labelProbability.probability
        
        labelProbabilities = _.values combinedLabelProbabilities
        thingsLeftToDraw = @thingsLeftToDraw()
        
        strokesCount = canvas.strokes().length
        
        # possibleThingFactor = 1.25 + 0.25 * (1 - thingsLeftToDraw.length / 10) * difficultyFactor
        possibleThingFactor = 1 + (0.5 - (1 / (strokesCount / 2 + 1.5))) * difficultyFactor
        
        for labelProbability in labelProbabilities
          labelProbability.easyProbability = Math.max labelProbability.symbolic, labelProbability.realistic
          labelProbability.hardProbability = labelProbability.symbolic + labelProbability.realistic
          labelProbability.hardProbability *= possibleThingFactor if labelProbability.label in thingsLeftToDraw
          
          labelProbability.probability = THREE.MathUtils.lerp labelProbability.easyProbability, labelProbability.hardProbability, difficultyFactor
        
        labelProbabilities.sort (a, b) => b.probability - a.probability
        
        top3Guesses = _.filter labelProbabilities[..2], (labelProbability) => labelProbability.probability > 0.01
        
        guessTexts = for guess in top3Guesses
          guessStyle = switch
            when guess.probability > 0.5 then '?'
            when guess.probability > 0.1 then '??'
            else '???'
          
          if @constructor.debug
            "#{guess.label}#{guessStyle} #{Math.round(guess.probability * 100)}% s:#{Math.round(guess.symbolic * 100)}% r:#{Math.round(guess.realistic * 100)}%"
          
          else
            "#{guess.label}#{guessStyle}"
        
        @guessesText guessTexts.join '<br/>'
        @pixeltoshClass 'thinking'
        
        requiredProbability = THREE.MathUtils.lerp 0.95, 1, difficultyFactor
        candidates = _.filter labelProbabilities[..2], (labelProbability) => labelProbability.probability > requiredProbability
        
        return unless candidates.length
        
        foundLabel = null
        for candidate in candidates
          if candidate.label in thingsLeftToDraw
            foundLabel = candidate.label
            break
        
        return unless foundLabel
        
        @guessesText '' unless @constructor.debug
        @pixeltoshClass 'got-it'
        
        drawing = canvas.getDrawing()
        @_addDrawnThing foundLabel, drawing
        
        @canvasText "#{foundLabel}!"
        
        Meteor.setTimeout =>
          @canvasText ""
          canvas.clear()
        ,
          if @constructor.debug then 3000 else 500
        
  end: ->
    @_endTimerAutorun.stop()
    @_evaluateAutorun.stop()
    
    Meteor.setTimeout =>
      return unless gameView = @drawQuickly.os.interface.getView DrawQuickly.Interface.Game
      gameView.showResults()
    ,
      500

  _chooseThingsToDraw: (allThingsToDraw) ->
    tenThings = _.shuffle(allThingsToDraw)[0...10]
    tenThings.sort()
    tenThings

  _addDrawnThing: (thing, drawing) ->
    thingsDrawn = @thingsDrawn()
    thingsDrawn.push thing
    @thingsDrawn thingsDrawn
    
    @drawings[thing] = drawing
    
    @end() if thingsDrawn.length is 10
  
  update: (gameTime) ->
    return unless timer = @timer()
    
    timer.update gameTime
