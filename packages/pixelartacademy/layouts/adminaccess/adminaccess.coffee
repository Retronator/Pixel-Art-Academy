AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Layouts.AdminAccess extends BlazeLayoutComponent
  @register 'PixelArtAcademy.Layouts.AdminAccess'

  loading: ->
    Meteor.loggingIn()

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
