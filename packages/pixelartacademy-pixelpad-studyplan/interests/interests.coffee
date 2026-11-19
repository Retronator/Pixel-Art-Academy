AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Interests extends StudyPlan.BottomPanel
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Interests'
  @register @id()

  onCreated: ->
    super arguments...
    
    @currentInterests = new ComputedField => @_prepareInterestsForOutput LOI.adventure.currentInterests()
      
    @plannedInterests = new ComputedField =>
      # Collect unique interests provided by added goals, excluding interests already gained.
      providedInterests = []
      
      for goal in @studyPlan.goals() when goal.added()
        providedInterests = _.union providedInterests, goal.interests()
      
      @_prepareInterestsForOutput _.difference providedInterests, LOI.adventure.currentInterests()
      
  _prepareInterestsForOutput: (referenceNames) ->
    interests = (IL.Interest.find referenceName for referenceName in referenceNames)
    _.pull interests, undefined
    _.sortBy interests, (interest) => _.lowerCase interest.name.translate().text
