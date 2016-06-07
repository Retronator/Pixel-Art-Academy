AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Practice.CheckInCalendarComponent extends AM.Component
  template: ->
    'PixelArtAcademy.Practice.CheckInCalendarComponent'

  showEntry: ->
    checkIn = @data()

    @showImage() or checkIn.text

  showImage: ->
    checkIn = @data()

    checkIn.artwork or checkIn.image or checkIn.post

  textStyle: ->
    checkIn = @data()

    color: "##{checkIn.character.colorObject().getHexString()}"

  linkColor: ->
    checkIn = @data()

    # Link should be 2 shades lighter than the text.
    checkIn.character.colorObject 2
