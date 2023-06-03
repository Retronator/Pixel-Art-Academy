AB = Artificial.Babel
AM = Artificial.Mirage

# Component for translating the text in-place.
class AB.Components.Translatable extends AM.Component
  @register 'Artificial.Babel.Components.Translatable'

  @Types:
    Text: 'text'
    TextArea: 'textarea'

  constructor: (@options = {}) ->
    super arguments...

    @options.type ?= @constructor.Types.Text

  onCreated: ->
    super arguments...

    # Reactively subscribe to the translation so that refresh on the translation will work.
    @autorun (computation) =>
      return unless translationOrKey = @data()
      return unless translationOrKey instanceof AB.Translation

      translation = translationOrKey

      @translationSubscription = AB.Translation.forId.subscribe @, translation._id

    @translation = new ComputedField =>
      return unless translationOrKey = @data()

      # Return refreshed translation if it was passed directly.
      return translationOrKey.refresh() if translationOrKey instanceof AB.Translation

      # Fetch translation for the parent component using the provided key.
      translationKey = translationOrKey
      parentComponent = @parentComponent()
      return unless parentComponent

      AB.translationForComponent parentComponent, translationKey

    @translated = new ComputedField =>
      return unless translation = @translation()

      translation.translate()

    @currentTranslationInfo = new ComputedField =>
      if translation = @translation()
        return unless translated = @translated()

        languageRegion = translated.language
        translationData = translation.translationData languageRegion

        return {translationData, languageRegion} if translationData

      # We don't have a translation (or the translation has no translations)
      # and will need to create it if the user types in something.
      languageRegion: @options.newTranslationLanguage ? AB.languagePreference()[0]

    @showTranslationSelector = new ReactiveField false

    @showNewTranslationInput = new ReactiveField false

  editable: -> @options.editable

  translations: ->
    return unless translation = @translation()

    translation.allTranslationData()

  newTranslationInfo: ->
    # Adding new translations starts as global by default.
    languageRegion: ''

  addTranslationText: ->
    addTranslationText = @options.addTranslationText?()?.translate().text
    addTranslationText or @translate("Add translation").text

  removeTranslationText: ->
    removeTranslationText = @options.removeTranslationText?()?.translate().text
    removeTranslationText or @translate("Remove translation").text
    
  text: ->
    translationOrKey = @data()
    @translated()?.text or translationOrKey

  events: ->
    super(arguments...).concat
      'click .current-translation .language': @onClickCurrentTranslationLanguage
      'click .new-translation .language': @onClickNewTranslationLanguage
      'click .translation-selector .language': @onClickTranslationSelectorLanguage
      'click .add-translation': @onClickAddTranslation
      'click .remove-translation': @onClickRemoveTranslation

  onClickCurrentTranslationLanguage: (event) ->
    @showTranslationSelector not @showTranslationSelector()

  onClickNewTranslationLanguage: (event) ->
    translationComponent = @currentComponent()
    translationComponent.showLanguageSelection not translationComponent.showLanguageSelection()

  onClickTranslationSelectorLanguage: (event) ->
    translationComponent = @currentComponent()
    translationComponent.showLanguageSelection not translationComponent.showLanguageSelection()

  onClickAddTranslation: (event) ->
    @showNewTranslationInput true

  onClickRemoveTranslation: (event) ->
    return unless translation = @translation()
    translationInfo = @currentData()

    AB.Translation.removeLanguage translation._id, translationInfo.languageRegion

  onTranslationInserted: (languageRegion, value) ->
    @options.onTranslationInserted? languageRegion, value

  onTranslationUpdated: (languageRegion, value) ->
    @options.onTranslationUpdated? languageRegion, value

  # Components

  class @Translation extends AM.Component
    @register 'Artificial.Babel.Components.Translatable.Translation'

    onCreated: ->
      super arguments...

      @translation = new ComputedField =>
        # Find translation document in the data context of the parent.
        @parentDataWith (data) => data instanceof AB.Translation

      translatableComponent = @ancestorComponentOfType AB.Components.Translatable

      @translatableInput = new AB.Components.Translatable.Input
        type: translatableComponent.options.type
        realtime: translatableComponent.options.realtime
        translation: => @translation()
        languageRegion: => @languageRegion()

      @languageSelection = new @constructor.LanguageSelection
        translation: => @translation()
        languageRegion: => @languageRegion()

      @showLanguageSelection = new ReactiveField()

    languageRegion: ->
      translationInfo = @data()
      translationInfo.languageRegion

    languageRegionCodes: ->
      translationInfo = @data()
      _.splitLanguageRegion translationInfo.languageRegion

    removeTranslationText: ->
      @callAncestorWith 'removeTranslationText'

    class @LanguageSelection extends AB.Components.LanguageSelection
      @register 'Artificial.Babel.Components.Translatable.Translation.LanguageSelection'

      constructor: (@options) ->
        super arguments...

      load: ->
        @options.languageRegion()

      save: (value) ->
        translation = @options.translation()

        currentLanguageRegion = @options.languageRegion()
        newLanguageRegion = value

        AB.Translation.moveLanguage translation._id, currentLanguageRegion, newLanguageRegion

  class @Input extends AM.DataInputComponent
    @register 'Artificial.Babel.Components.Translatable.Input'

    constructor: (@options) ->
      super arguments...

      @type = @options.type
      @realtime = @options.realtime if @options.realtime?

    load: ->
      return unless translation = @options.translation()
      languageRegion = @options.languageRegion()

      translationData = translation.translationData languageRegion

      translationData?.text

    save: (value) ->
      languageRegion = @options.languageRegion()

      return if @callAncestorWith 'onTranslationUpdated', languageRegion, value

      AB.Translation.update @options.translation()._id, languageRegion, value

    placeholder: ->
      placeholderTextComponent = @ancestorComponentWith (component) => component.options?.placeholderText

      if placeholderTextComponent
        translationLanguage = if placeholderTextComponent.options.placeholderInTargetLanguage then [@options.languageRegion()] else AB.languagePreference()

        # Get the placeholder text (or translation).
        placeholder = placeholderTextComponent.options.placeholderText()

        # Translate it if we were given a translation.
        placeholder = placeholder.translate(translationLanguage).text if placeholder?.translate

      placeholder ?= @translate("Enter translation for %%language%%").text

      # Replace language placeholder with actual language.
      language = @options.languageRegion()
      placeholder = placeholder.replace '%%language%%', language

      placeholder

  class @NewTranslation extends AM.Component
    @register 'Artificial.Babel.Components.Translatable.NewTranslation'
    template: -> 'Artificial.Babel.Components.Translatable.Translation'

    onCreated: ->
      super arguments...

      @translation = new ComputedField =>
        # Find translation document in the data context of the parent.
        @parentDataWith (data) => data instanceof AB.Translation

      translatableComponent = @ancestorComponentOfType AB.Components.Translatable

      # Replace translatable input with one that will create the translation after first entry.
      @translatableInput = new AB.Components.Translatable.NewInput
        type: translatableComponent.options.type
        translation: => @translation()
        languageRegion: => @languageRegion()

      @languageSelection = new @constructor.LanguageSelection
        languageRegion: => @languageRegion()

      @showLanguageSelection = new ReactiveField()

    languageRegion: ->
      translationInfo = @data()
      @languageSelection.selectedLanguageRegion() ? translationInfo.languageRegion

    languageRegionCodes: ->
      _.splitLanguageRegion @languageRegion()

    class @LanguageSelection extends AB.Components.LanguageSelection
      @register 'Artificial.Babel.Components.Translatable.NewTranslation.LanguageSelection'

      constructor: (@options) ->
        super arguments...

        # Prepare a field to store the selection locally.
        @selectedLanguageRegion = new ReactiveField null

      load: ->
        @options.languageRegion()

      save: (value) ->
        newLanguageRegion = value
        @selectedLanguageRegion newLanguageRegion

  class @NewInput extends @Input
    @register 'Artificial.Babel.Components.Translatable.NewInput'

    constructor: (@options) ->
      super arguments...

      @type = @options.type
      @realtime = false

    load: -> ''

    save: (value) ->
      languageRegion = @options.languageRegion()

      unless @callAncestorWith 'onTranslationInserted', languageRegion, value
        # If we have the translation, we can insert the new value right into.
        if translation = @options.translation()
          AB.Translation.update translation._id, languageRegion, value

      # Hide the new input.
      @callAncestorWith 'showNewTranslationInput', false
