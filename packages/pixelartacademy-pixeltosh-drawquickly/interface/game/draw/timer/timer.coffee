AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Draw.Timer extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Draw.Timer'
  @register @id()

  time: ->
    return 0 unless timer = @data()
    timer.time()
    
  minutes: ->
    Math.floor Math.ceil(@time()) / 60

  seconds: ->
    seconds = Math.ceil(@time()) % 60
    seconds.toString().padStart 2, '0'
