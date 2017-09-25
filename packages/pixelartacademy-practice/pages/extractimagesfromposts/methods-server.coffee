AE = Artificial.Everywhere
AT = Artificial.Telepathy
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Meteor.methods
  'PixelArtAcademy.Practice.CheckIn.extractImagesFromPosts': ->
    # Only an admin can perform this processing.
    LOI.Authorize.admin()

    # Go over all check-ins that have a post, but no image.
    checkIns = PAA.Practice.CheckIn.documents.find(
      post: $exists: true
      image: $exists: false
    ).fetch()

    processedCount = 0
    console.log "Processing check-in posts with posts but without images."
    for checkIn in checkIns
      try
        console.log "Processing:", checkIn.post.url
        imageUrl = Meteor.call 'PixelArtAcademy.Practice.CheckIn.getExternalUrlImage', checkIn.post.url

        processedCount++
        PAA.Practice.CheckIn.documents.update checkIn._id,
          $set:
            image:
              url: imageUrl

      catch error
        console.log error

    console.log "Successfully processed", processedCount, "out of", checkIns.length, "check-ins."
