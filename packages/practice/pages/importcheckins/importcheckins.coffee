AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Pages.ImportCheckIns extends AM.Component
  @register 'PixelArtAcademy.Practice.Pages.ImportCheckIns'

  events: ->
    super.concat
      'submit .upload-form': @onSubmitUploadForm

  onSubmitUploadForm: (event) ->
    event.preventDefault()

    csvFile = @$('.csvFile')[0].files[0]
    passphrase = @$('.passphrase').val()

    reader = new FileReader()

    reader.onload = (event) ->
      data = "HEADER#{event.target.result}"
      encryptedData = CryptoJS.AES.encrypt(data, passphrase).toString()

      Meteor.call 'PixelArtAcademy.Practice.CheckIn.import', encryptedData

    reader.readAsText csvFile
