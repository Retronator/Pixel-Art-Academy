AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Practice.CheckInCalendarComponent extends AM.Component
  template: ->
    'PixelArtAcademy.Practice.CheckInCalendarComponent'

  checkIn: ->
    # Fetch full check-in data (we have a bare object with just the id).
    checkIn = @currentData()

    PAA.Practice.CheckIn.documents.findOne checkIn._id

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
