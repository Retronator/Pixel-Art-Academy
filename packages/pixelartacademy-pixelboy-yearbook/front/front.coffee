AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Yearbook.Front extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook.Front'
  @register @id()

  constructor: (@yearbook) ->
    super

  onCreated: ->
    super
    
  visibleClass: ->
    'visible' if @yearbook.showFront()
    
  events: ->
    super.concat
      'click': => @yearbook.showFront false
