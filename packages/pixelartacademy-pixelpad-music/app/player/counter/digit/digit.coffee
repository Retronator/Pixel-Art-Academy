AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Music.Player.Counter.Digit extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Music.Player.Counter.Digit'
  @register @id()
  
  @numberHeight = 7

  onRendered: ->
    super arguments...
    
    @$numbers = @$('.numbers')
    
    @showNumber @_currentNumber or 0
    
  showNumber: (number) ->
    @_currentNumber = number
    return unless @$numbers
    
    @$numbers.css
      top: "#{-@constructor.numberHeight * number}rem"
