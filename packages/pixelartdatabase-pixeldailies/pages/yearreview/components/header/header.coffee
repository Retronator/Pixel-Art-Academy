AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Components.Header extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Header'

  year: ->
    parseInt FlowRouter.getParam 'year'

  isCurrentYear: ->
    currentYear = new Date().getFullYear()
    @year() is currentYear
