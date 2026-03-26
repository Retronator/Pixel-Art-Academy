AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Music.Player.Counter extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Music.Player.Counter'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @onesDigit = new @constructor.Digit
    @tensDigit = new @constructor.Digit
    @hundredsDigit = new @constructor.Digit
    
    @musicApp = @ancestorComponentOfType PAA.PixelPad.Apps.Music
    
    @tapeSides = new ComputedField =>
      @musicApp.system()?.tape()?.getSidesWithTapeProgress()
    
    @sideIndex = new ComputedField => PAA.PixelPad.Systems.Music.state 'sideIndex'
    @trackIndex = new ComputedField => PAA.PixelPad.Systems.Music.state 'trackIndex'
    
    @trackInfo = new ComputedField =>
      return unless tapeSides = @tapeSides()
      
      sideIndex = @sideIndex()
      trackIndex = @trackIndex()
      return unless sideIndex? and trackIndex?
      
      tapeSides[sideIndex].tracks[trackIndex]
    
    @autorun (computation) =>
      return unless trackInfo = @trackInfo()
      currentTime = PAA.PixelPad.Systems.Music.state 'currentTime'
      return unless currentTime?
      
      tapeProgress = PAA.Music.Tape.durationToTapeProgress trackInfo.startTime + currentTime
      
      ones = tapeProgress % 10
      
      tens = Math.floor (tapeProgress / 10) % 10
      tens += ones - 9 if ones > 9
      
      onesAndTens = tapeProgress % 100
      
      hundreds = Math.floor (tapeProgress / 100) % 10
      hundreds += onesAndTens - 99 if onesAndTens > 99
      
      @onesDigit.showNumber ones
      @tensDigit.showNumber tens
      @hundredsDigit.showNumber hundreds
