AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Yearbook.Middle extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook.Middle'
  @register @id()

  constructor: (@yearbook) ->
    super

  onCreated: ->
    super
    
  visibleClass: ->
    'visible' unless @yearbook.showFront()

  events: ->
    super.concat
      'click': => @yearbook.showFront true
