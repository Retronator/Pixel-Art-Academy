AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Input control for editing translation values.
class LOI.Components.TranslationInput extends AM.Component
  @register 'LandsOfIllusions.Components.TranslationInput'

  onCreated: ->
    super

    # We create a translatable that is always editable.
    @translatable = new AB.Components.Translatable
      editable: true

  renderTranslatable: ->
    # We need to manually render the translatable (instead using Render) because
    # we want to retain data context (the translation document coming from the parent).
    @translatable.renderComponent? @currentComponent()
