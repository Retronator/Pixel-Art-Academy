AB = Artificial.Babel
AM = Artificial.Mirage

class AB.Components.Translatable extends AM.Component
  @register 'Artificial.Babel.Components.Translatable'

  constructor: (@translationKey) ->
    super

  onCreated: ->
    super

    @translation = new ComputedField =>
      parentComponent = @parentComponent()
      return unless parentComponent

      AB.translationForComponent parentComponent, @translationKey

    @translated = new ComputedField =>
      AB.translate @translation(), @translationKey
