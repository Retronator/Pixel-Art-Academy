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
      parentComponent?.babelServer.translationForComponent parentComponent, @translationKey

    @translated = new ComputedField =>
      AB.Server.translate @translation(), @translationKey
