AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Practice.Pages.Admin.Scripts extends AM.Component
  @id: -> 'PixelArtAcademy.Practice.Pages.Admin.Scripts'
  @register @id()

  @convertCheckIns: new AB.Method name: "#{@id()}.convertCheckIns"

  events: ->
    super.concat
      'click .convert-check-ins': => @constructor.convertCheckIns()
