AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.Character extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Character'

  constructor: (@terminal) ->
    super
    
    @characterId = new ReactiveField null
    
    @character = new ComputedField =>
      LOI.Character.getInstance @characterId()

  onCreated: ->
    super

    AB.subscribeNamespace 'LandsOfIllusions.Character.Behavior.Perk',
      subscribeProvider: @

  setCharacterId: (characterId) ->
    @characterId characterId

  backButtonCallback: ->
    # We return to main menu.
    @_returnToMenu()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  traits: ->
    @character().behavior.part.properties.personality.part.traitsString()

  activities: ->
    @character().behavior.part.properties.activities.toString()

  environment: ->
    @character().behavior.part.properties.environment.part

  perks: ->
    @character().behavior.part.properties.perks.toString()

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .save-draft-button': @onClickSaveDraftButton
      'click .modify-personality-button': @onClickModifyPersonalityButton
      'click .modify-activities-button': @onClickModifyActivitiesButton
      'click .modify-environment-button': @onClickModifyEnvironmentButton
      'click .modify-perks-button': @onClickModifyPerksButton

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
        LOI.Character.approveBehavior character.id(), (error) =>
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

  onClickModifyEnvironmentButton: (event) ->
    @terminal.switchToScreen @terminal.screens.environment

  onClickModifyPerksButton: (event) ->
    @terminal.switchToScreen @terminal.screens.perks
