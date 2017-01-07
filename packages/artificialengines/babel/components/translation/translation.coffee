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

      @subscribe 'Artificial.Babel.Translation.withId', translation._id, AB.userLanguagePreference()

  text: ->
    translation = @data()
    return unless translation

    # Refresh the data context document with the text field, which will appear once the subscription kicks in.
    translation.refresh()

    AB.translate(translation).text
