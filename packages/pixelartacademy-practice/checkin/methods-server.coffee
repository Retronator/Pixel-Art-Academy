AT = Artificial.Telepathy
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Meteor.methods
  # Process a post url
  'PixelArtAcademy.Practice.CheckIn.getExternalUrlImage': (url) ->
    check url, String

    ogImageRegex = /og:image"\s*content="([^"]+)"/

    # See if url is already an image.
    try
      response = HTTP.get url
      contentType = response.headers['content-type']

      # Return the url directly if content type is an image.
      return url if /image/.test contentType

    catch
      throw new Meteor.Error 'invalid-argument', "The provided url is not valid."
    
    # It is not, so let's parse the url to find what service it belongs to.
    if /twitter\.com/.test url
      tweetId = url.split('/status/')[1]
      apiUrl = 'statuses/show/' + tweetId
      tweetData = AT.Twitter.get apiUrl

      throw new Meteor.Error 'unavailable', "There was an error communicating with the server. Either the tweet doesn't exist, or the server is down - try again later!" unless tweetData
      throw new Meteor.Error 'invalid-argument', "The tweet has no images associated with it." unless tweetData.entities?.media?[0]?.media_url_https

      return tweetData.entities.media[0].media_url_https

    else if /imgur\.com/.test url
      # HACK: Look for the og:image tag in the head and remove the ?fb parameter.
      results = ogImageRegex.exec response.content
      return results[1].replace('?fb', '') if results[1]

    # We didn't find a custom importer so let's try a general approach and look for the og:image tag in the head.
    results = ogImageRegex.exec response.content
    return results[1] if results?[1]

    # We don't know what to do with this url yet.
    throw new Meteor.Error 'unsupported', "We do not yet support importing images from the given website. The check-in will include a link to your post."

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

  # Import check-ins from the imported database and assign them to the given character.
  'PixelArtAcademy.Practice.CheckIn.import': (characterId) ->
    check characterId, Match.DocumentId

    # Make sure the character belongs to the current user.
    LOI.Authorize.characterAction characterId

    user = Meteor.user()

    # Try to match by registered emails.
    if user.registered_emails
      for email in user.registered_emails
        continue unless email.verified

        # Find the checkIns in imported data.
        importedCheckIns = PAA.Practice.ImportedData.CheckIn.documents.find(
          backerEmail: email.address
        ).fetch()

        console.log "Found", importedCheckIns.length, "check-ins for email", email.address

        Meteor.call 'PixelArtAcademy.Practice.CheckIn.insert', characterId, importedCheckIn.text, importedCheckIn.image, importedCheckIn.timestamp for importedCheckIn in importedCheckIns
