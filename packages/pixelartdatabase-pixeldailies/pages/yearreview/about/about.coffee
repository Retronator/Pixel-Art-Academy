AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.About extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.About'

  year: ->
    FlowRouter.getParam 'year'

  background: ->
    # The second artwork from the backgrounds array is used on the about page.
    PADB.PixelDailies.Pages.YearReview.Years[@year()].backgrounds[1]
