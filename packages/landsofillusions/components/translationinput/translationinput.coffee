AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Input control for editing translation values.
class LOI.Components.TranslatiddonInput extends AM.Component
  @register 'LandsOfIllusions.Components.TranslationInput'

  onCreated: ->
    super

    translation = @currentData()

    @translatable = new AB.Components.Translatable translation,
      editable: true
