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
