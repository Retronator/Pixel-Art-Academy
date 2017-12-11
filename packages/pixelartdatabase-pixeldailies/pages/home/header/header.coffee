AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Home.Header extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Home.Header'

  year: ->
    parseInt AB.Router.getParameter 'year'

  isCurrentYear: ->
    currentYear = new Date().getFullYear()
    @year() is currentYear

  homePath: ->
    AB.Router.createUrl 'PixelArtDatabase.PixelDailies.Pages.Home'
