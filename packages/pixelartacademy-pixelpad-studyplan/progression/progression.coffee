AM = Artificial.Mirage
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Progression extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Progression'
  @register @id()

  onCreated: ->
    super arguments...

    @studyPlan = @ancestorComponentOfType StudyPlan
    @panelDisplayed = new ReactiveField false
    @controlsReady = new ReactiveField false
    @closing = new ReactiveField false
    @revealedLevel = new ReactiveField StudyPlan.displayedProgressionLevel()
    @speechText = new ReactiveField null
    
    @lotusDriving = new ReactiveField true
    @lotusOpen = new ReactiveField false
    
  onRendered: ->
    super arguments...
    
    await _.waitForSeconds 1
    return unless @isRendered()
    
    @panelDisplayed true
    
    await _.waitForSeconds 1
    return unless @isRendered()

    @_lotusLeft = if @currentLevel() < 3 then 200 else 10
    @$('.lotus').css left: "#{@_lotusLeft}rem"
    
    await _.waitForSeconds 1
    return unless @isRendered()
    @lotusDriving false
    
    await _.waitForSeconds 0.5
    return unless @isRendered()
    
    @lotusOpen true
    @controlsReady true
    @say "Welcome to the Study Plan where you will shape your learning journey."

  say: (text) ->
    @speechText text

  speechBalloonOptions: ->
    text: => @speechText()

  panelDisplayedClass: ->
    'displayed' if @panelDisplayed()

  levels: ->
    [
      number: 1
      name: "Progress tracking"
      description: "Use the Study Plan to see what you're working on."
    ,
      number: 2
      name: "Short-term goals"
      description: "Choose what to work on next with short-term goals."
    ,
      number: 3
      name: "Mid-term goals"
      description: "Plan one step ahead by exploring what future goals look like."
    ,
      number: 4
      name: "Long-term goals"
      description: "Choose an end goal and plan backwards how to get there."
    ]
  
  currentLevel: ->
    @revealedLevel() + 1
    
  levelIsCurrent: ->
    level = @currentData()
    level.number is @currentLevel()

  levelHasUnlockButton: ->
    @controlsReady() and not @closing() and @levelIsCurrent() and @currentLevel() <= StudyPlan.unlockedProgressionLevel()

  levelHasStartButton: ->
    level = @currentData()
    @controlsReady() and not @closing() and level.number is @revealedLevel() and @revealedLevel() >= StudyPlan.unlockedProgressionLevel()

  revealed: ->
    level = @currentData()
    level.number <= @revealedLevel()

  levelRevealedClass: ->
    'revealed' if @revealed()
  
  lotusDrivingClass: ->
    'driving' if @lotusDriving()
    
  lotusOpenClass: ->
    'open' if @lotusOpen()

  events: ->
    super(arguments...).concat
      'click .unlock-button': @onClickUnlockButton
      'click .start-button': @onClickStartButton

  onClickUnlockButton: (event) ->
    return unless @levelHasUnlockButton()

    # Reveal locally so the parent keeps the screen open and the map paused between levels.
    @revealedLevel @currentData().number

    @_moveLotusLeft() if @revealedLevel() is 3

  _moveLotusLeft: ->
    return unless @_lotusLeft is 200

    # Keep Start unavailable and hide speech while Mini Retro gets in and changes parking spots.
    @controlsReady false
    speechText = @speechText()
    @say null
    @lotusOpen false

    await _.waitForSeconds 0.5
    return unless @isRendered()

    @lotusDriving true
    @_lotusLeft = 10
    @$('.lotus').css left: "#{@_lotusLeft}rem"

    await _.waitForSeconds 1
    return unless @isRendered()
    @lotusDriving false

    await _.waitForSeconds 0.5
    return unless @isRendered()

    @lotusOpen true
    @say speechText
    @controlsReady true

  onClickStartButton: (event) ->
    return unless @levelHasStartButton()
    @closing true
    @lotusOpen false
    @say null

    await _.waitForSeconds 0.5
    return unless @isRendered()

    @$('.lotus').css
      left: "-250rem"
      transition: "left 1s ease-in"
      
    @lotusDriving true
    
    await _.waitForSeconds 1
    return unless @isRendered()
    
    @studyPlan.finishProgression @revealedLevel()
