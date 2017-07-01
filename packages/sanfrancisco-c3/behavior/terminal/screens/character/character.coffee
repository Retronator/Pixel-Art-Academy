AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

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

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .save-draft-button': @onClickSaveDraftButton
      'click .modify-personality-button': @onClickModifyPersonalityButton

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
