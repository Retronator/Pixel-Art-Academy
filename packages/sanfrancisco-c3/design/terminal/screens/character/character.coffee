AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Character extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Character'

  constructor: (@terminal) ->
    super arguments...
    
    @characterId = new ReactiveField null
    
    @character = new ComputedField =>
      LOI.Character.getInstance @characterId()

    @_characterRenderer = null
    @characterRenderer = new ComputedField =>
      return unless character = @character()

      @_characterRenderer?.destroy()
      @_characterRenderer = character.avatar.createRenderer()

      @_characterRenderer
      
  destroy: ->
    @character.stop()
    @characterRenderer.stop()
    @_characterRenderer?.destroy()

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

  avatarPreviewOptions: ->
    rotatable: true
    viewingAngle: @terminal.viewingAngle
    renderer: @characterRenderer()

  avatarBodyPreviewOptions: ->
    renderer: @characterRenderer()
    drawOutfit: false

  avatarOutfitPreviewOptions: ->
    renderer: @characterRenderer()
    drawBody: false

  events: ->
    super(arguments...).concat
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

    @terminal.showDialog
      message: "You are ordering the construction of this agent. It will become available for behavior setup."
      confirmButtonText: "Confirm"
      confirmButtonClass: "positive-button"
      cancelButtonText: "Cancel"
      confirmAction: =>
        LOI.Character.approveDesign character._id, (error) =>
          if error
            console.error error
            return

          # Close the terminal and proceed with the story.
          # TODO: Homage cinematic to Ghost in the Shell.
          LOI.adventure.deactivateActiveItem()

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
      message = "Do you really want to delete the whole agent design? You cannot undo this action."

    # Double check that the user wants to be removed from their character.
    @terminal.showDialog
      message: message
      confirmButtonText: if designApproved then "Retire" else "Delete"
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

  onClickBodyPart: (event) ->
    @terminal.screens.avatarPart.pushPart @character().avatar.body,
      renderer: @characterRenderer()
      drawOutfit: false

    @terminal.switchToScreen @terminal.screens.avatarPart

  onClickOutfitPart: (event) ->
    @terminal.screens.avatarPart.pushPart @character().avatar.outfit,
      renderer: @characterRenderer()

    @terminal.switchToScreen @terminal.screens.avatarPart
