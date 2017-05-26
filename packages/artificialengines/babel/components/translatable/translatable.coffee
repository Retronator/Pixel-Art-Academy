AB = Artificial.Babel
AM = Artificial.Mirage

# Component for translating the text in-place.
class AB.Components.Translatable extends AM.Component
  @register 'Artificial.Babel.Components.Translatable'

  @Types:
    Text: 'text'
    TextArea: 'textarea'

  constructor: (@options = {}) ->
    super

    @options.type ?= @constructor.Types.Text

  onCreated: ->
    super

    @translation = new ComputedField =>
      return unless @translationOrKey = @data()

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
    @currentLanguageRegion = new ReactiveField AB.userLanguagePreference()?[0] or AB.defaultLanguage

    @currentTranslationInfo = new ComputedField =>
      return unless translation = @translation()

      languageRegion = @currentLanguageRegion()
      translationData = translation.translationData languageRegion

      {translationData, languageRegion}

    # When translation gets loaded, translate it using the current language,
    # see which language we're actually displaying and update accordingly.
    @autorun (computation) =>
      return unless translation = @translation()

      translationResult = translation.translate [@currentLanguageRegion()]

      Tracker.nonreactive =>
        @currentLanguageRegion translationResult.language

  editable: ->
    editable = Artificial.Babel.inTranslationMode() or @options.editable

    # Create the input control just-in-time.
    if editable
      Tracker.nonreactive => @_createInput()

    editable

  _createInput: ->
    @translatableInput ?= new @constructor.Input
      type: @options.type
      translation: @translation
      languageRegion: @currentLanguageRegion
      placeholder: @options.placeholder

  translations: ->
    return unless translation = @translation()

    translation.allTranslationData()

  addTranslationText: ->
    addTranslationText = @options.addTranslationText?()
    addTranslationText or @translate("Add translation").text

  class @Input extends AM.DataInputComponent
    @register 'Artificial.Babel.Components.Translatable.Input'
    
    constructor: (@options) ->
      super

      @type = @options.type

    load: ->
      return unless translation = @options.translation()
      languageRegion = @options.languageRegion()
      
      translationData = translation.translationData languageRegion
      
      translationData?.text

    save: (value) ->
      languageRegion = @options.languageRegion()

      AB.Translation.update @options.translation()._id, languageRegion, value

    placeholder: ->
      placeholder = @options.placeholder?()
      placeholder ?= @translate("Enter translation for %%language%%").text

      # Replace language placeholder with actual language.
      language = @options.languageRegion()
      placeholder = placeholder.replace '%%language%%', language

      placeholder

  class @Translation extends AM.Component
    @register 'Artificial.Babel.Components.Translatable.Translation'

    onCreated: ->
      super

      @translation = new ComputedField =>
        # Find translation document in the data context of the parent.
        @parentDataWith (data) => data instanceof AB.Translation

      @translatableInput = new AB.Components.Translatable.Input
        type: AB.Components.Translatable.Types.Text
        translation: => @translation()
        languageRegion: => @languageRegion()

      @languageSelection = new @constructor.LanguageSelection
        translation: => @translation()
        languageRegion: => @languageRegion()

    languageRegion: ->
      translationInfo = @data()
      translationInfo.languageRegion

    class @LanguageSelection extends AB.Components.LanguageSelection
      @register 'Artificial.Babel.Components.Translatable.Translation.LanguageSelection'

      constructor: (@options) ->
        super

      load: ->
        @options.languageRegion()

      save: (value) ->
        translation = @options.translation()

        currentLanguageRegion = @options.languageRegion()
        newLanguageRegion = value

        AB.Translation.move translation._id, currentLanguageRegion, newLanguageRegion
