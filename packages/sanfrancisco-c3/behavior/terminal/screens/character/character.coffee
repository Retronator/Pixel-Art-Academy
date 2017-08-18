AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Factors = LOI.Character.Behavior.Personality.Factors
FocalPoints = LOI.Character.Behavior.FocalPoints

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

    personality = @character().behavior.personality

    for factorIndex, factor of Factors
      factorsProperty = personality.part.properties.factors
      factorPart = factorsProperty.partsByOrder[factor.options.type]

      traitParts = factorPart.properties.traits.parts()
      continue unless traitParts.length

      enabledTraits = _.filter traitParts, (traitPart) -> traitPart.properties.weight.options.dataLocation() > 0
      traits = traits.concat enabledTraits

    traitNames = (_.capitalize trait.properties.name.options.dataLocation() for trait in traits)

    traitNames.join ', '
    
  focalPoints: ->
    # Start with the default focal points.
    focalPoints =
      "#{FocalPoints.Names.Sleep}": 
        nameEditable: false
        hoursPerWeek: 0
        
      "#{FocalPoints.Names.Job}":
        nameEditable: false
        hoursPerWeek: 0
        
      "#{FocalPoints.Names.School}":
        nameEditable: false
        hoursPerWeek: 0
        
      "#{FocalPoints.Names.Drawing}":
        nameEditable: false
        hoursPerWeek: 0

    # Add all character's focal points.
    for focalPointPart in @character().behavior.focalPoints.property.parts()
      focalPointName = focalPointPart.properties.name.options.dataLocation()
      focalPointHoursPerWeek = focalPointPart.properties.hoursPerWeek.options.dataLocation()
      
      unless focalPoints[focalPointName]
        focalPoints[focalPointName] = nameEditable: true

      focalPoints[focalPointName].part = focalPointPart
      focalPoints[focalPointName].hoursPerWeek = focalPointHoursPerWeek

    # Return an array.
    for focalPointName, focalPoint of focalPoints
      _.extend {}, focalPoint, name: focalPointName

  hoursSleep: ->
    # Find sleep focal point.
    sleepFocalPoint = _.find @character().behavior.focalPoints.property.parts(), (focalPointPart) =>
      focalPointName = focalPointPart.properties.name.options.dataLocation()
      focalPointName is FocalPoints.Names.Sleep

    sleepFocalPoint?.properties.hoursPerWeek.options.dataLocation() or 0

  hoursAfterSleep: ->
    24 * 7 - @hoursSleep()

  hoursJobSchool: ->
    total = 0

    # Find job and sleep focal points.
    for focalPointName in [FocalPoints.Names.Job, FocalPoints.Names.School]
      focalPoint = _.find @character().behavior.focalPoints.property.parts(), (focalPointPart) =>
        focalPointPart.properties.name.options.dataLocation() is focalPointName

      total += focalPoint?.properties.hoursPerWeek.options.dataLocation() or 0

    total

  hoursAfterJobSchool: ->
    @hoursAfterSleep() - @hoursJobSchool()

  hoursFocalPoints: ->
    total = 0

    for focalPointPart in @character().behavior.focalPoints.property.parts()
      focalPointName = focalPointPart.properties.name.options.dataLocation()

      continue if focalPointName in [FocalPoints.Names.Job, FocalPoints.Names.School, FocalPoints.Names.Sleep]

      total += focalPointPart.properties.hoursPerWeek.options.dataLocation()

    total

  extraHoursPerWeek: ->
    @hoursAfterJobSchool() - @hoursFocalPoints()

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
      'change .new-focal-point': @onChangeNewFocalPoint

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

  onChangeNewFocalPoint: (event) ->
    $input = $(event.target)
    name = $input.val()
    return unless name.length

    # Clear input for next entry.
    $input.val('')

    newPart = @character().behavior.focalPoints.property.newPart 'FocalPoint'

    newPart.options.dataLocation
      name: name
      hoursPerWeek: 0

  # Components

  class @FocalPointHoursPerWeek extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.FocalPointHoursPerWeek'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Number
      @placeholder = 0
      @customAttributes =
        min: 0
        step: 1

    load: ->
      focalPointInfo = @data()
      focalPointInfo.hoursPerWeek

    save: (value) ->
      focalPointInfo = @data()

      if focalPointInfo.part
        part = focalPointInfo.part
        part.properties.hoursPerWeek.options.dataLocation value * @_saveFactor()

      else
        characterComponent = @ancestorComponentOfType C3.Behavior.Terminal.Character
        newPart = characterComponent.character().behavior.focalPoints.property.newPart 'FocalPoint'

        newPart.options.dataLocation
          name: focalPointInfo.name
          hoursPerWeek: value * @_saveFactor()

    _saveFactor: ->
      1

  class @FocalPointHoursPerDay extends @FocalPointHoursPerWeek
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.FocalPointHoursPerDay'

    load: ->
      focalPointInfo = @data()
      Math.round(focalPointInfo.hoursPerWeek / 0.7) / 10

    _saveFactor: ->
      7

  class @FocalPointName extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.FocalPointName'

    load: ->
      focalPointInfo = @data()
      focalPointInfo.name

    save: (value) ->
      focalPointInfo = @data()

      if value.length
        # Update focal point name.
        focalPointInfo.part.properties.name.options.dataLocation value

      else
        # Delete focal point.
        focalPointInfo.part.options.dataLocation.remove()
