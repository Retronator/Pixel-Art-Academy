AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Factors = LOI.Character.Behavior.Personality.Factors
Activities = LOI.Character.Behavior.Activities

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
    # Start with the default focal points.
    activities =
      "#{Activities.Keys.Sleep}": 
        nameEditable: false
        hoursPerWeek: 0
        
      "#{Activities.Keys.Job}":
        nameEditable: false
        hoursPerWeek: 0
        
      "#{Activities.Keys.School}":
        nameEditable: false
        hoursPerWeek: 0
        
      "#{Activities.Keys.Drawing}":
        nameEditable: false
        hoursPerWeek: 0

    # Add all character's focal points.
    for activityPart in @character().behavior.part.properties.activities.parts()
      activityKey = activityPart.properties.key.options.dataLocation()
      activityHoursPerWeek = activityPart.properties.hoursPerWeek.options.dataLocation()
      
      unless activities[activityKey]
        activities[activityKey] = nameEditable: true

      activities[activityKey].part = activityPart
      activities[activityKey].hoursPerWeek = activityHoursPerWeek

    # Return an array.
    for activityName, activity of activities
      _.extend {}, activity, key: activityName

  hoursSleep: ->
    # Find sleep focal point.
    sleepActivity = _.find @character().behavior.part.properties.activities.parts(), (activityPart) =>
      activityName = activityPart.properties.key.options.dataLocation()
      activityName is Activities.Keys.Sleep

    sleepActivity?.properties.hoursPerWeek.options.dataLocation() or 0

  hoursAfterSleep: ->
    24 * 7 - @hoursSleep()

  hoursJobSchool: ->
    total = 0

    # Find job and sleep focal points.
    for activityName in [Activities.Keys.Job, Activities.Keys.School]
      activity = _.find @character().behavior.part.properties.activities.parts(), (activityPart) =>
        activityPart.properties.key.options.dataLocation() is activityName

      total += activity?.properties.hoursPerWeek.options.dataLocation() or 0

    total

  hoursAfterJobSchool: ->
    @hoursAfterSleep() - @hoursJobSchool()

  hoursActivities: ->
    total = 0

    for activityPart in @character().behavior.part.properties.activities.parts()
      activityKey = activityPart.properties.key.options.dataLocation()

      continue if activityKey in [Activities.Keys.Job, Activities.Keys.School, Activities.Keys.Sleep]

      total += activityPart.properties.hoursPerWeek.options.dataLocation()

    total

  extraHoursPerWeek: ->
    @hoursAfterJobSchool() - @hoursActivities()

  extraHoursPerDay: ->
    Math.round(@extraHoursPerWeek() / 0.7) / 10

  extraHoursTooLow: ->
    @extraHoursPerWeek() < 20

  extraHoursTooHigh: ->
    @extraHoursPerWeek() > 50

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .save-draft-button': @onClickSaveDraftButton
      'click .modify-personality-button': @onClickModifyPersonalityButton
      'change .new-focal-point': @onChangeNewActivity

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

  onChangeNewActivity: (event) ->
    $input = $(event.target)
    name = $input.val()
    return unless name.length

    # Clear input for next entry.
    $input.val('')

    activityType = LOI.Character.Part.Types.Behavior.Activity.options.type
    newPart = @character().behavior.part.properties.activities.newPart activityType

    newPart.options.dataLocation
      key: name
      hoursPerWeek: 0

  # Components

  class @ActivityHoursPerWeek extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.ActivityHoursPerWeek'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Number
      @placeholder = 0
      @customAttributes =
        min: 0
        step: 1

    load: ->
      activityInfo = @data()
      activityInfo.hoursPerWeek

    save: (value) ->
      activityInfo = @data()

      if activityInfo.part
        part = activityInfo.part
        part.properties.hoursPerWeek.options.dataLocation value * @_saveFactor()

      else
        characterComponent = @ancestorComponentOfType C3.Behavior.Terminal.Character

        activityType = LOI.Character.Part.Types.Behavior.Activity.options.type
        newPart = characterComponent.character().behavior.part.properties.activities.newPart activityType

        newPart.options.dataLocation
          key: activityInfo.key
          hoursPerWeek: value * @_saveFactor()

    _saveFactor: ->
      1

  class @ActivityHoursPerDay extends @ActivityHoursPerWeek
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.ActivityHoursPerDay'

    load: ->
      activityInfo = @data()
      Math.round(activityInfo.hoursPerWeek / 0.7) / 10

    _saveFactor: ->
      7

  class @ActivityName extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.ActivityName'

    load: ->
      activityInfo = @data()
      activityInfo.key

      # TODO: Get translation for key.

    save: (value) ->
      activityInfo = @data()

      if value.length
        # Update focal point name.
        activityInfo.part.properties.key.options.dataLocation value

      else
        # Delete focal point.
        activityInfo.part.options.dataLocation.remove()
