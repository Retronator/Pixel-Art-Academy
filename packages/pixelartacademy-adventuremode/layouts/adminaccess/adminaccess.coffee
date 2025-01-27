AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Layouts.AdminAccess extends BlazeComponent
  @register 'PixelArtAcademy.Layouts.AdminAccess'

  onCreated: ->
    super arguments...
    
    Meteor.reconnect()
  
  loading: ->
    Meteor.loggingIn()
