PADB = PixelArtDatabase

class PADB.Upload.Context extends PADB.Upload.Context
  constructor: ->
    super
    
    @slingshot = new Slingshot.Upload @options.name
  
  upload: (file, callback) ->
    validationError = @slingshot.validate file

    if validationError
      console.error 'Error validating file.', error
      return

    @slingshot.send file, (error, fileUrl) ->
      if error
        console.error 'Error uploading file.', error
        return

      callback fileUrl
