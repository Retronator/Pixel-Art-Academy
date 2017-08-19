AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Factors = LOI.Character.Behavior.Personality.Factors

class C3.Behavior.Terminal.Character extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Character'

  constructor: (@terminal) ->
    super
    
    @characterId = new ReactiveField null
    
    @character = new ComputedField =>
      characterId = @characterId()
      
      Tracker.nonreactive =>
        new LOI.Character.Instance characterId

  onCreated: ->
    super

  setCharacterId: (characterId) ->
    @characterId characterId

  backButtonCallback: ->
    # We return to main menu.
    @_returnToMenu()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  personalityTraits: ->
    traits = []

    personality = @character().behavior.part.properties.personality

    for factorIndex, factor of Factors
      factorsProperty = personality.part.properties.factors
      continue unless factorPart = factorsProperty.partsByOrder[factor.options.type]

      traitParts = factorPart.properties.traits.parts()
      continue unless traitParts.length

      enabledTraits = _.filter traitParts, (traitPart) -> traitPart.properties.weight.options.dataLocation() > 0
      traits = traits.concat enabledTraits

    # TODO: Replace with translated names.
    traitNames = (_.capitalize trait.properties.key.options.dataLocation() for trait in traits)

    traitNames.join ', '
    
  activities: ->
    activities = []

    for activityPart in @character().behavior.part.properties.activities.parts()
      activityHoursPerWeek = activityPart.properties.hoursPerWeek.options.dataLocation()
      activities.push activityPart if activityHoursPerWeek > 0

    # TODO: Replace with translated names.
    activityNames = (_.capitalize activity.properties.key.options.dataLocation() for activity in activities)

    activityNames.join ', '

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .save-draft-button': @onClickSaveDraftButton
      'click .modify-personality-button': @onClickModifyPersonalityButton
      'click .modify-activities-button': @onClickModifyActivitiesButton

  onClickDoneButton: (event) ->
    character = @currentData()

    # If the behavior is already approved, there is nothing to do, simply return to main menu.
    if character.document().behaviorApproved
      @_returnToMenu()
      return

    @terminal.showDialog
      message: "You are initializing the agent with its behavior profile. They will become ready for deployment."
      confirmButtonText: "Confirm"
      confirmButtonClass: "positive-button"
      cancelButtonText: "Cancel"
      confirmAction: =>
        LOI.Character.approveBehavior character.id, (error) =>
          if error
            console.error error
            return

          # Close the terminal and proceed with the story.
          LOI.adventure.deactivateCurrentItem()

          behaviorControl = LOI.adventure.currentLocation()
          behaviorControl.listeners[0].startScript label: 'CompleteCharacter'

  onClickSaveDraftButton: (event) ->
    # We simply return to main menu.
    @_returnToMenu()

  _returnToMenu: ->
    @terminal.switchToScreen @terminal.screens.mainMenu

  onClickModifyPersonalityButton: (event) ->
    @terminal.switchToScreen @terminal.screens.personality

  onClickModifyActivitiesButton: (event) ->
    @terminal.switchToScreen @terminal.screens.activities
