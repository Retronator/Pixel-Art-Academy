LOI = LandsOfIllusions

class LOI.Assets.Upload.Context extends LOI.Assets.Upload.Context
  upload: (file, callback, errorCallback) ->
    upload = new Slingshot.Upload @options.name

    validationError = upload.validate file

    if validationError
      console.error 'Error validating file.', validationError, file
      errorCallback validationError
      return

    upload.send file, (uploadError, fileUrl) ->
      if uploadError
        console.error 'Error uploading file.', uploadError
        errorCallback uploadError
        return

      callback fileUrl

    upload
