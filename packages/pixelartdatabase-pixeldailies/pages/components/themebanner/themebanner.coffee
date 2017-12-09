AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Components.ThemeBanner extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Components.ThemeBanner'

  dateTitle: ->
    theme = @data()

    theme.time.toLocaleString Artificial.Babel.currentLanguage(),
      weekday: 'long'
      month: 'long'
      day: 'numeric'
      year: 'numeric'

  themeImageUrl: ->
    theme = @data()
    theme.topSubmissions?[0]?.images[0].imageUrl
