LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Global extends LOI.Adventure.Global
  @id: -> 'PixelArtAcademy.StudyGuide.Global'

  @initialize()

  constructor: ->
    super arguments...

    # Globally subscribe to Study Guide activities. Note that we purposefully do not require the subscription to be
    # ready for this global class to be ready since we don't want the adventure to require waiting on activities to
    # arrive. They are only used from delayed interactions and we assume they will be initialized by the time such an
    # interaction is demanded.
    PAA.StudyGuide.Activity.initializeAll()

    @goals = {}

    # Instantiate goals when they arrive.
    @autorun (computation) =>
      goalClasses = PAA.Learning.Goal.getClasses()

      for goalClass in goalClasses
        goalId = goalClass.id()

        # Only instantiate goals from the Study Guide.
        continue if @goals[goalId] or not PAA.StudyGuide.Goals[goalId]

        @goals[goalId] = new goalClass

  tasks: ->
    _.flatten (goal.tasks() for goalId, goal of @goals)
