AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Lesson extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Lesson'
  @register @id()

  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess
    
    @lesson = new ComputedField => @chess.lessonManager()?.lesson()
    
    @activeStepIndex = new ReactiveField 0
    @activeStep = new ComputedField =>
      # Note: We have to wait until we're actually rendered so the step doesn't get rendered twice due to reflows.
      return unless @isRendered()
      
      @lesson()?.steps[@activeStepIndex()]
    
    @autorun (computation) =>
      return unless lesson = @lesson()
      return unless activeStep = @activeStep()
      
      if activeStep.failed()
        @chess.lessonManager().rewind activeStep.retryGameState()

      if activeStep.completed() and not @_completedCountIncreased
        if @activeStepIndex() < lesson.steps.length - 1
          @activeStepIndex @activeStepIndex() + 1
          
        else
          completedCount = lesson.state('completedCount') or 0
          lesson.state 'completedCount', completedCount + 1
          @_completedCountIncreased = true

  onDestroyed: ->
    super arguments...

    Meteor.clearTimeout @_revertTimeout if @_revertTimeout
