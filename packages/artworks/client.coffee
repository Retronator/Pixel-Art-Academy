PAA = PixelArtAcademy

class PAA.Artworks extends PAA.Artworks
  @_uploader = new Slingshot.Upload "artworks"

  console.log "UPLOADER", @_uploader

  @upload: (artworkId, file) ->
    error = @_uploader.validate file

    if error
      console.error 'Error validating', error
      return

    @_uploader.send file, (error, downloadUrl) ->
      if error
        console.error 'Error uploading', error
        return

      console.log "UPLOAD SUCCESS", downloadUrl

      Meteor.call "artworkUpdate", artworkId,
        $set:
          'image.url': downloadUrl
