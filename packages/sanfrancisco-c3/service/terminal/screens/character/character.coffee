AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Service.Terminal.Character extends AM.Component
  @register 'SanFrancisco.C3.Service.Terminal.Character'

  constructor: (@terminal) ->
    super arguments...
    
    @characterId = new ReactiveField null
    
    @character = new ComputedField =>
      LOI.Character.getInstance @characterId()

  onCreated: ->
    super arguments...
    
    nameInputOptions =
      addTranslationText: => @translation "Add language variant"
      removeTranslationText: => @translation "Remove language variant"
      newTranslationLanguage: ''

    @fullNameInput = new LOI.Components.TranslationInput _.extend {}, nameInputOptions,
      placeholderText: => LOI.Character.Avatar.noNameTranslation()
      placeholderInTargetLanguage: true
      onTranslationInserted: (languageRegion, value) =>
        LOI.Character.updateName @characterId(), languageRegion, value

      onTranslationUpdated: (languageRegion, value) =>
        LOI.Character.updateName @characterId(), languageRegion, value

        # Return true to prevent the default update to be executed.
        true

  setCharacterId: (characterId) ->
    @characterId characterId

  renderFullNameInput: ->
    @fullNameInput.renderComponent @currentComponent()

  dialogPreviewStyle: ->
    # Set the color to character's color.
    character = @currentData()

    color: "##{character.avatar.colorObject()?.getHexString()}"

  backButtonCallback: ->
    # We return to main menu.
    @_returnToMenu()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  traits: ->
    @character()?.behavior.part.properties.personality.part.traitsString() or "None"

  activities: ->
    @character()?.behavior.part.properties.activities.toString() or "None"

  environment: ->
    @character()?.behavior.part.properties.environment.part

  perks: ->
    @character()?.behavior.part.properties.perks.toString() or "None"

  events: ->
    super(arguments...).concat
      'click .done-button': @onClickDoneButton
      'click .delete-button': @onClickDeleteButton

  onClickDoneButton: (event) ->
    @_returnToMenu()

  onClickDeleteButton: (event) ->
    character = @currentData()
    activated = character.document().activated

    if activated
      message = "Do you really want to retire this agent? You will lose control of them and you cannot undo this action."

    else
      message = "Do you really want to delete this agent design? You cannot undo this action."

    # Double check that the user wants to be removed from their character.
    @terminal.showDialog
      message: message
      confirmButtonText: if activated then "Retire" else "Delete"
      confirmButtonClass: "danger-button"
      cancelButtonText: "Cancel"
      confirmAction: =>
        # Remove the user from the character.
        LOI.Character.removeUser character._id, (error) =>
          if error
            console.error error
            return

          # Return to main menu.
          @_returnToMenu()

  _returnToMenu: ->
    @terminal.switchToScreen @terminal.screens.mainMenu
