AB = Artificial.Babel
AM = Artificial.Mirage

# Component for translating the text in-place.
class AB.Components.Translatable extends AM.Component
  @register 'Artificial.Babel.Components.Translatable'

  constructor: (@translationOrKey) ->
    super

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
