AB = Artificial.Babel
AM = Artificial.Mirage
IL = Illustrapedia

class IL.Pages.Admin.Interests.Interest extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'Illustrapedia.Pages.Admin.Interests.Interest'
  @register @id()

  displayName: ->
    interest = @data()
    translation = AB.translate interest.name

    # Return the translated name or ID.
    if translation.language and translation.text then translation.text else interest._id

  class @Name extends AM.Component
    @register 'Illustrapedia.Pages.Admin.Interests.Interest.Name'
  
    constructor: (@options) ->
      super
  
    onCreated: ->
      super
  
      # We create a translatable that is always editable.
      @translatable = new AB.Components.Translatable _.extend {}, @options,
        editable: true
  
    renderTranslatable: ->
      # We need to manually render the translatable (instead using Render) because
      # we want to retain data context (the translation document coming from the parent).
      @translatable.renderComponent @currentComponent()

  class @Synonyms extends AM.DataInputComponent
    @register 'Illustrapedia.Pages.Admin.Interests.Interest.Synonyms'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.TextArea

    load: ->
      @currentData()?.synonyms?.join '\n'

    save: (value) ->
      synonyms = value.split '\n'
      _.pull synonyms, ''
      IL.Interest.update @currentData()._id, $set: 'synonyms': synonyms
