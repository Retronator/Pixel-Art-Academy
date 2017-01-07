PAA = PixelArtAcademy

class PAA.Practice extends PAA.Practice
  @_uploader = new Slingshot.Upload "checkIns"
  
  @upload: (file, callback) ->
    error = @_uploader.validate file

    if error
      console.error 'Error validating', error
      return

    @_uploader.send file, (error, downloadUrl) ->
      if error
        console.error 'Error uploading', error
        return

      callback downloadUrl
