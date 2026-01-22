AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.ActiveGoals extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.ActiveGoals'
  @register @id()

  constructor: (@studyPlan) ->
    super arguments...
  
    @headerHeight = 15
    @animationDuration = 0.35
    
  onCreated: ->
    super arguments...
    
    @contentHeight = new ReactiveField 0
    @previousContentHeight = new ReactiveField 0
    
    @opened = new ReactiveField false
    
    @activeGoalIds = new ComputedField =>
      return [] unless goalsData = StudyPlan.state 'goals'
      
      activeGoalIds = (goalId for goalId, goal of goalsData when not goal.markedComplete)
      activeGoalIds.sort()
      activeGoalIds
    ,
      EJSON.equals
    
    @activeGoals = new ComputedField =>
      activeGoals = (PAA.Learning.Goal.getAdventureInstanceForId goalId for goalId in @activeGoalIds())
      _.sortBy activeGoals, (goal) => goal.displayName()

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
    
  activeGoalsStyle: ->
    if @opened()
      bottom: "#{@contentHeight()}px"

    else
      bottom: 0
      
  canRemove: ->
    goal = @currentData()
    StudyPlan.canRemoveGoal goal.id()
  
  events: ->
    super(arguments...).concat
      'click .title': @onClickTitle
      'click .active-goal .name': @onClickActiveGoalName
  
  onClickTitle: (event) ->
    @opened not @opened()
    
  onClickActiveGoalName: (event) ->
    goal = @currentData()
    @studyPlan.selectGoal goal.id()
