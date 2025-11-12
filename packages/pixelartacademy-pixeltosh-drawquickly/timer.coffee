AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Timer
  constructor: (time) ->
    @time = new ReactiveField time
    @running = new ReactiveField false
    
  start: ->
    @running true
    
  update: (appTime) ->
    return unless @running()
    
    time = @time() - appTime.elapsedAppTime
    
    if time < 0
      time = 0
      @running false
    
    @time time
