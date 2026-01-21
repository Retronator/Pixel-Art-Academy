AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.GoalInfo extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.GoalInfo'
  @register @id()
  
  @width = 120

  onCreated: ->
    super arguments...
    
    @studyPlan = @ancestorComponentOfType StudyPlan
    @goalId = new ReactiveField null
    @goal = new ComputedField =>
      return unless goalId = @goalId()
      PAA.Learning.Goal.getAdventureInstanceForId goalId

    # Set goal ID, but don't unset it so that info can be present during fade out.
    @autorun (computation) =>
      return unless goalId = @studyPlan.selectedGoalId()
      @goalId goalId
  
  visibleClass: ->
    'visible' if @studyPlan.selectedGoalId()
    
  goalCompletedClass: ->
    'goal-completed' if @goal()?.completed()
    
  markedComplete: ->
    return unless goalId = @goalId()
    StudyPlan.isGoalMarkedComplete goalId
    
  goalComponent: ->
    return unless goalId = @goalId()
    blueprint = @studyPlan.blueprint()
    goalComponentsById = blueprint.goalComponentsById()
    goalComponentsById[goalId]
    
  goalNode: ->
    return unless goalComponent = @goalComponent()
    goalComponent.data()
  
  canRemove: ->
    return unless goalNode = @goalNode()
    
    # Goal can be removed when it's a leaf in the hierarchy.
    not (goalNode.forwardGoalNodes.length or goalNode.sidewaysGoalNodes.length)
  
  removeButtonDisabledAttribute: ->
    disabled: true unless @canRemove()
    
  events: ->
    super(arguments...).concat
      'click .remove-button': @onClickRemoveButton
  
  onClickRemoveButton: (event) ->
    @studyPlan.removeGoal @goalId()
    
  class @MarkedComplete extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.StudyPlan.GoalInfo.MarkedComplete'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Checkbox
    
    onCreated: ->
      super arguments...
      
      @goalInfo = @ancestorComponentOfType StudyPlan.GoalInfo
      
    customAttributes: ->
      disabled: true unless @goalInfo.goal()?.completed()
    
    load: ->
      return unless goalNode = @goalInfo.goalNode()
      goalNode.markedComplete()
    
    save: (value) ->
      @goalInfo.goalComponent().markComplete value
