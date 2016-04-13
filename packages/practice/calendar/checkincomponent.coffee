AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Practice.CheckInCalendarComponent extends AM.Component
  template: ->
    'PixelArtAcademy.Practice.CheckInCalendarComponent'

  showFigure: ->
    checkIn = @currentData()

    checkIn.artwork or checkIn.image or checkIn.post or checkIn.text
