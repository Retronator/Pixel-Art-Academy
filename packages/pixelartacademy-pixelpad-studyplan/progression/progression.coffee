AM = Artificial.Mirage
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Progression extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Progression'
  @register @id()

  constructor: ->
    super arguments...
    
    @timelapsePlaying = new ReactiveField false
    @timelapsePlayed = new ReactiveField false
    @timelapseReplayed = new ReactiveField false
    
  onCreated: ->
    super arguments...

    @studyPlan = @ancestorComponentOfType StudyPlan
    @panelDisplayed = new ReactiveField false
    @controlsReady = new ReactiveField false
    
    @levelsInfo = [
      level: StudyPlan.ProgressionLevels.ShortTermGoals
      name: "Short-term goals"
      description: "Choose what to work on next with short-term goals."
    ,
      level: StudyPlan.ProgressionLevels.MidTermGoals
      name: "Mid-term goals"
      description: "Add mid-term goals beyond short-term goals to see what comes next."
    ,
      level: StudyPlan.ProgressionLevels.LongTermGoals
      name: "Long-term goals"
      description: "Decide on a long-term goal and plan backwards how to get there."
    ]
    
  onRendered: ->
    super arguments...
    
    await _.waitForSeconds if StudyPlan.unlockedProgressionLevel() then 0.1 else 1
    return unless @isRendered()
    
    @panelDisplayed true
    
    if @showIntro()
      # Wait for the panel's opening transition before starting the intro.
      await _.waitForSeconds 0.5
      return unless @isRendered()

      @startTimelapse()

    else
      @controlsReady true

  onDestroyed: ->
    super arguments...

    Meteor.clearTimeout @_timelapseTimeout

    @timelapsePlaying false
    @timelapsePlayed false
    @timelapseReplayed false
    
  startTimelapse: ->
    Meteor.clearTimeout @_timelapseTimeout
    
    @controlsReady false
    @timelapsePlaying true

  finishTimelapse: ->
    # Cancel the pending completion when playback is skipped before replaying.
    Meteor.clearTimeout @_timelapseTimeout
    
    @timelapsePlaying false
    @timelapsePlayed true
    @controlsReady true

  panelDisplayedClass: ->
    'displayed' if @panelDisplayed()

  showIntro: ->
    not StudyPlan.unlockedProgressionLevel()
  
  timelapsePlayedClass: ->
    'timelapse-played' if @timelapsePlayed()
    
  timelapseData: ->
    src: '/pixelartacademy/pixelpad/apps/studyplan/intro.webm'
    onEnded: =>
      controlsReadyDelay = if @timelapseReplayed() then 1000 else 5000
      @timelapsePlayed true
      
      @_timelapseTimeout = Meteor.setTimeout =>
        @finishTimelapse()
      ,
        controlsReadyDelay
    
  levelRevealed: ->
    levelInfo = @currentData()
    levelInfo.level <= StudyPlan.unlockedProgressionLevel()
  
  levelUnlockingClass: ->
    'unlocking' if @levelHasUnlockButton()
    
  levelRevealedClass: ->
    'revealed' if @levelRevealed()

  levelNumber: ->
    levelInfo = @currentData()
    levelInfo.level - 1

  levelHasStartButton: ->
    level = @currentData()
    return unless level.level is StudyPlan.currentProgressionLevel()

    @controlsReady()
  
  levelHasUnlockButton: ->
    levelInfo = @currentData()

    # We unlock levels one by one.
    levelToBeUnlocked = StudyPlan.unlockedProgressionLevel() + 1
    return unless levelInfo.level is levelToBeUnlocked
  
    # Make sure the level can be unlocked.
    return unless levelToBeUnlocked <= StudyPlan.currentProgressionLevel()
    
    @controlsReady()

  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .unlock-button': @onClickUnlockButton
      'click .start-button': @onClickStartButton
      'click .replay-button': @onClickReplayButton
  
  onClick: (event) ->
    @finishTimelapse() if @timelapsePlaying()
  
  onClickUnlockButton: (event) ->
    levelInfo = @currentData()

    StudyPlan.unlockedProgressionLevel levelInfo.level

  onClickStartButton: (event) ->
    # Start button on the intro screen also unlocks the level.
    StudyPlan.unlockedProgressionLevel StudyPlan.ProgressionLevels.Intro unless StudyPlan.unlockedProgressionLevel()
    
    # Close the progression panel.
    @studyPlan.finishProgression()
  
  onClickReplayButton: (event) ->
    @timelapseReplayed true
    @startTimelapse()
