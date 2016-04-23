AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Layouts.AdminAccess extends BlazeLayoutComponent
  @register 'PixelArtAcademy.Layouts.AdminAccess'

  loading: ->
    Meteor.loggingIn() or not Roles.subscription.ready()

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
