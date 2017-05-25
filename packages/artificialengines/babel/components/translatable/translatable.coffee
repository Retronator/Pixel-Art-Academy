AB = Artificial.Babel
AM = Artificial.Mirage

# Component for translating the text in-place.
class AB.Components.Translatable extends AM.Component
  @register 'Artificial.Babel.Components.Translatable'

  @Types:
    Text: 'text'
    TextArea: 'textarea'

  constructor: (@translationOrKey, @options = {}) ->
    super
    
    @options.type ?= @constructor.Types.Text

  onCreated: ->
    super

    @translation = new ComputedField =>
      return unless @translationOrKey

      # Return translation if it was passed directly.
      return @translationOrKey if @translationOrKey instanceof AB.Translation

      # Fetch translation for the parent component using the provided key.
      translationKey = @translationOrKey
      parentComponent = @parentComponent()
      return unless parentComponent

      AB.translationForComponent parentComponent, translationKey

    @translated = new ComputedField =>
      return unless translation = @translation()

      AB.translate translation

    # Start with user's preferred language.
    @currentLanguage = new ReactiveField AB.userLanguagePreference()?[0] or AB.defaultLanguage

  editable: ->
    editable = Artificial.Babel.inTranslationMode() or @options.editable

    # Create the input control just-in-time.
    if editable
      Tracker.nonreactive => @_createInput()

    editable

  _createInput: ->
    @translatableInput ?= new @constructor.Input @

  addTranslationText: ->
    addTranslationText = @options.addTranslationText?()
    addTranslationText or @translate("Add translation").text

  class @Input extends AM.DataInputComponent
    @register 'Artificial.Babel.Components.Translatable.Input'
    
    constructor: (@translatable) ->
      super

      @type = @translatable.options.type

    load: ->
      return unless translation = @translatable.translation()
      language = @translatable.currentLanguage()
      
      translationData = translation.translation language
      
      translationData?.text

    save: (value) ->
      language = @translatable.currentLanguage()

      AB.Translation.update @translatable.translation()._id, language, value

    placeholder: ->
      placeholder = @translatable.options.placeholder?()
      placeholder ?= @translate("Enter translation for %%language%%").text

      # Replace language placeholder with actual language.
      language = @translatable.currentLanguage()
      placeholder = placeholder.replace '%%language%%', language

      placeholder

  class @ExistingTranslation extends AM.Component
    @register 'Artificial.Babel.Components.Translatable.ExistingTranslation'
