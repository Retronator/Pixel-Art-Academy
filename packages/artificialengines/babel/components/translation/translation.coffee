AB = Artificial.Babel
AM = Artificial.Mirage

class AB.Components.Translation extends AM.Component
  @register 'Artificial.Babel.Components.Translation'

  onCreated: ->
    super

    # Reactively subscribe to the current language's translation.
    @autorun =>
      translation = @data()
      return unless translation

      @translationSubscription = AB.Translation.forId.subscribe @, translation._id, AB.userLanguagePreference()

  showLoading: ->
    # We should show loading if translation has no data and the subscription isn't ready.
    not @translation()?.translations and not translationSubscription?.ready()

  translation: ->
    translation = @data()
    return unless translation

    # Refresh the data context document with the text field, which will appear once the subscription kicks in.
    translation.refresh()
