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
      slow: 90
      medium: 60
      fast: 30
    medium:
      slow: 135
      medium: 90
      fast: 45
    hard:
      slow: 180
      medium: 120
      fast: 60
  
  constructor: (@drawQuickly) ->
    @canvasText = new ReactiveField ""
    @pixeltoshClass = new ReactiveField ''
    @guessesText = new ReactiveField ""
    
    @timer = new ReactiveField null
    @canvas = new ReactiveField null
    
    @thingsToDraw = new ReactiveField []
    @thingsDrawn = new ReactiveField []
    @thingsLeftToDraw = new AE.LiveComputedField => _.difference @thingsToDraw(), @thingsDrawn()
    
    # Set default values.
    @difficulty = 'easy'
    @time = 120
  
  destroy: ->
    @thingsLeftToDraw.stop()
    @_endTimerAutorun?.stop()
    @_evaluateAutorun?.stop()
  
  setDifficulty: (@difficulty) ->
  
  setTime: (@time) ->
  
  reset: ->
    @canvasText ""
    @pixeltoshClass ''
    @guessesText ""
    
    @timer null
    @canvas null
    
    @thingsToDraw []
    @thingsDrawn []
    
  start: ->
    timer = new DrawQuickly.Timer @time
    timer.start()
    @timer timer
    
    canvas = @drawQuickly.os.interface.allChildComponentsOfType(DrawQuickly.Interface.Game.Draw.Canvas)[0]
    @canvas canvas
    
    # End game when the timer runs out.
    @_endTimerAutorun = @drawQuickly.autorun (computation) =>
      return if timer.running()
      return if timer.time()
      computation.stop()
      
      canvas.endDrawing()
      @canvasText "Game over"
      @end()
    
    # Choose things to draw.
    difficultyFactor = @constructor.difficultyFactors[@difficulty]
    
    @thingsToDraw @_chooseThingsToDraw @constructor.thingsByDifficulty[@difficulty]

    @drawings = {}
    
    # Evaluate what is drawn.
    @_evaluateAutorun = @drawQuickly.autorun (computation) =>
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
        
        strokes = canvas.getPlainStrokes()
        @_addDrawnThing foundLabel, strokes
        
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

  _addDrawnThing: (thing, strokes) ->
    thingsDrawn = @thingsDrawn()
    thingsDrawn.push thing
    @thingsDrawn thingsDrawn
    
    @drawings[thing] = strokes
    
    @end() if thingsDrawn.length is 10
  
  update: (gameTime) ->
    return unless timer = @timer()
    
    timer.update gameTime
