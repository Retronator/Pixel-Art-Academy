AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelBoy.Apps.StudyPlan.Goal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Goal'
  @register @id()

  constructor: (goalOrOptions) ->
    if goalOrOptions instanceof PAA.Learning.Goal
      @goal = goalOrOptions

    else
      {@goal, @state, @blueprint} = goalOrOptions

      @position = @state.field 'position',
        equalityFunction: EJSON.equals
        lazyUpdates: true
        
      @expanded = @state.field 'expanded',
        lazyUpdates: true
  
    @goalTasks = []
    
    for task in @goal.tasks
      @goalTasks.push
        task: task

    # TODO: Calculate positioning info.

  onCreated: ->
    super

    # Subscribe to all interests of this goal.
    @autorun (computation) =>
      for interest in _.union @goal.interests(), @goal.requiredInterests()
        IL.Interest.forSearchTerm.subscribe interest

  goalStyle: ->
    return unless @state and @blueprint

    # Make sure we have position present, as it will disappear when goal is being deleted.
    return unless position = @position()

    scale = @blueprint.camera().scale()

    position: 'absolute'
    left: "#{position.x * scale}rem"
    top: "#{position.y * scale}rem"

  expandedClass: ->
    'expanded' if @expanded?()

  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest

  $getConnectorByRequiredInterestId: (id) ->
    $interest = @$(".required-interests .interest[data-id='#{id}'] .connector")
    return $interest if $interest.length

    # HACK: Seems like the interest isn't rendered yet. Force a reactive recomputation after a delay.
    dependency = new Tracker.Dependency
    dependency.depend()

    Meteor.setTimeout =>
      dependency.changed()
    ,
      100

  events: ->
    super.concat
      'mousedown .pixelartacademy-pixelboy-apps-studyplan-goal': @onMouseDownGoal
      'click .pixelartacademy-pixelboy-apps-studyplan-goal > .name': @onClickName
      'click .required-interests .interest': @onClickRequiredInterest
      'mousedown .required-interests .interest': @onMouseDownRequiredInterest
      'mouseup .required-interests .interest': @onMouseUpRequiredInterest
      'mousedown .provided-interests': @onMouseDownProvidedInterests

  onMouseDownGoal: (event) ->
    # We only deal with drag & drop for goals inside the canvas.
    return unless @blueprint
    
    # Prevent browser select/dragging behavior
    event.preventDefault()
    
    @blueprint.startDrag
      goalId: @goal.id()
      goalPosition: @position()

  onClickName: (event) ->
    return unless @expanded

    @expanded not @expanded()

  onClickRequiredInterest: (event) ->
    interestDocument = @currentData()

    @blueprint.studyPlan.goalSearch().setInterest interestDocument

  onMouseDownRequiredInterest: (event) ->
    interestDocument = @currentData()

    # Prevent selection.
    event.preventDefault()

    # Prevent goal drag.
    event.stopPropagation()

    @blueprint.modifyConnection
      goalId: @goal.id()
      interest: interestDocument.referenceString()

  onMouseUpRequiredInterest: (event) ->
    interestDocument = @currentData()

    @blueprint.endConnection
      goalId: @goal.id()
      interest: interestDocument.referenceString()

  onMouseDownProvidedInterests: (event) ->
    # Prevent selection.
    event.preventDefault()
    
    # Prevent goal drag.
    event.stopPropagation()

    @blueprint.startConnection @goal.id()
