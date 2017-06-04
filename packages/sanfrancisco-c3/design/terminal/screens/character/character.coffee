AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Character extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Character'

  constructor: (@terminal) ->
    super
    
    @characterId = new ReactiveField null
    
    @character = new ComputedField =>
      characterId = @characterId()
      
      Tracker.nonreactive =>
        new LOI.Character.Instance characterId

  onCreated: ->
    super
    
    nameInputOptions =
      addTranslationText: => @translation "Add language variant"
      removeTranslationText: => @translation "Remove language variant"
      newTranslationLanguage: ''

    @fullNameInput = new LOI.Components.TranslationInput _.extend {}, nameInputOptions,
      placeholderText: => LOI.Character.Avatar.noNameTranslation()
      placeholderInTargetLanguage: true
      onTranslationInserted: (languageRegion, value) =>
        LOI.Character.updateName @characterId(), 'fullName', languageRegion, value

      onTranslationUpdated: (languageRegion, value) =>
        LOI.Character.updateName @characterId(), 'fullName', languageRegion, value

        # Return true to prevent the default update to be executed.
        true

    @shortNameInput = new LOI.Components.TranslationInput _.extend {}, nameInputOptions,
      placeholderText: => @character().avatar.shortName()
      onTranslationInserted: (languageRegion, value) =>
        LOI.Character.updateName @characterId(), 'shortName', languageRegion, value

      onTranslationUpdated: (languageRegion, value) =>
        LOI.Character.updateName @characterId(), 'shortName', languageRegion, value

        # Return true to prevent the default update to be executed.
        true

  setCharacterId: (characterId) ->
    @characterId characterId

  renderFullNameInput: ->
    @fullNameInput.renderComponent @currentComponent()

  renderShortNameInput: ->
    @shortNameInput.renderComponent @currentComponent()

  dialogPreviewStyle: ->
    # Set the color to character's color.
    character = @currentData()

    color: "##{character.avatar.colorObject()?.getHexString()}"

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .save-draft-button': @onClickSaveDraftButton
      'click .delete-button': @onClickDeleteButton
      'click .body-part': @onClickBodyPart
      'click .outfit-part': @onClickOutfitPart

  onClickDoneButton: (event) ->
    character = @currentData()

    # If the design is already approved, there is nothing to do, simply return to main menu.
    if character.document().designApproved
      @_returnToMenu()
      return

    LOI.Character.approveDesign character.id, (error) =>
      if error
        console.error error
        return

      # Close the terminal and proceed with the story.
      # TODO: Homage cinematic to Ghost in the Shell.
      LOI.adventure.deactivateCurrentItem()

      designControl = LOI.adventure.currentLocation()
      designControl.listeners[0].startScript label: 'MakingOfACyborg'

  onClickSaveDraftButton: (event) ->
    # We simply return to main menu.
    @_returnToMenu()

  onClickDeleteButton: (event) ->
    character = @currentData()
    designApproved = character.document().designApproved

    if designApproved
      message = "Do you really want to retire this agent? You will lose control of them and you cannot undo this action."

    else
      message = "Do you really want to delete this design? You cannot undo this action."

    # Double check that the user wants to be removed from their character.
    dialog = new LOI.Components.Dialog
      message: message
      buttons: [
        text: if designApproved then "Retire" else "Delete"
        value: true
      ,
        text: "Cancel"
      ]

    LOI.adventure.showActivatableModalDialog
      dialog: dialog
      callback: =>
        if dialog.result
          # Remove the user from the character.
          LOI.Character.removeUser character.id, (error) =>
            if error
              console.error error
              return

            # Return to main menu.
            @_returnToMenu()

  _returnToMenu: ->
    @terminal.switchToScreen @terminal.screens.mainMenu

  onClickBodyPart: (event) ->
    @terminal.screens.avatarPart.setPart @character().avatar.body
    @terminal.switchToScreen @terminal.screens.avatarPart

  onClickOutfitPart: (event) ->
    @terminal.screens.avatarPart.setPart @character().avatar.outfit
    @terminal.switchToScreen @terminal.screens.avatarPart
