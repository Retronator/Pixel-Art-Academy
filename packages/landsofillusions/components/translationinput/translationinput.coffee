AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Input control for editing translation values.
class LOI.Components.TranslationInput extends AM.Component
  @register 'LandsOfIllusions.Components.TranslationInput'

  constructor: (@options) ->
    super arguments...
  
  onCreated: ->
    super arguments...

    # We create a translatable that is always editable.
    @translatable = new AB.Components.Translatable _.extend {}, @options,
      editable: true

  renderTranslatable: ->
    # We need to manually render the translatable (instead using Render) because
    # we want to retain data context (the translation document coming from the parent).
    @translatable.renderComponent @currentComponent()
