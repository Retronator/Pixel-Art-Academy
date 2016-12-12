AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Tablet.Apps.Prospectus extends HQ.Items.Tablet.OS.App
  @register 'Retronator.HQ.Items.Tablet.Apps.Prospectus'

  @id: -> 'Retronator.HQ.Items.Tablet.Apps.Prospectus'
  @url: -> 'pixelartacademy'

  @fullName: -> "Pixel Art Academy Prospectus"

  @description: ->
    "
      Informational package about studying at Retropolis Academy of Art.
    "

  @initialize()

  onCreated: ->
    super
