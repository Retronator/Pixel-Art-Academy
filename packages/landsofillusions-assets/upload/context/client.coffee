LOI = LandsOfIllusions

class LOI.Assets.Upload.Context extends LOI.Assets.Upload.Context
  constructor: ->
    super arguments...
    
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
