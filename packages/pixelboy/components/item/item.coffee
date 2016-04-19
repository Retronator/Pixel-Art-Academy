AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.Components.Item extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Components.Item"

  constructor: (@pixelBoy) ->

  onCreated: ->

  events: ->
    super.concat
      'click .deactivate-button': @onClickDeactivateButton

  onClickDeactivateButton: (event) ->
    @pixelBoy.deactivate()
    
  draw: (appTime) ->
    # Any component based draw routines can go here.
