AE = Artificial.Everywhere
AM = Artificial.Mirage
PAA = PixelArtAcademy

Calendar = PAA.PixelBoy.Apps.Calendar

class Calendar.Providers.Practice.CheckInComponent extends AM.Component
  template: ->
    'PixelArtAcademy.PixelBoy.Apps.Calendar.Providers.Practice.CheckInComponent'
    
  onCreated: ->
    super
    
    @characterInstance = new ComputedField =>
      checkIn = @checkIn()
      return unless checkIn?.character?._id

      LOI.Character.getInstance checkIn.character._id

  checkIn: ->
    # Fetch full check-in data (we have a bare object with just the id).
    checkIn = @currentData()

    PAA.Practice.CheckIn.documents.findOne checkIn._id

  showEntry: ->
    checkIn = @currentData()

    @showImage() or checkIn.text

  showImage: ->
    checkIn = @currentData()

    checkIn.artwork or checkIn.image or checkIn.post

  showAvatar: ->
    return unless character = @characterInstance()

    # We have avatar if the body field has any data.
    character.document()?.avatar.body

  textStyle: ->
    checkIn = @currentData()

    color: "##{checkIn.character.colorObject().getHexString()}"

  linkColor: ->
    checkIn = @currentData()

    # Link should be 2 shades lighter than the text.
    checkIn.character.colorObject 2
