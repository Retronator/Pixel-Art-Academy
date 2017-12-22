AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Layouts.AdminAccess extends BlazeComponent
  @register 'PixelArtAcademy.Layouts.AdminAccess'

  loading: ->
    Meteor.loggingIn()
