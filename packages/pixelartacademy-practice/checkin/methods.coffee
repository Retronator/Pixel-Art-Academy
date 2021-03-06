AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Practice.CheckIn.insert.method (characterId, time) ->
  check characterId, Match.DocumentId
  check time, Match.OptionalOrNull Date

  # Make sure the user can perform this character action.
  LOI.Authorize.characterAction characterId

  # We create a new check-in for the given character.
  checkIn =
    time: time or new Date()
    character:
      _id: characterId

  PAA.Practice.CheckIn.documents.insert checkIn

PAA.Practice.CheckIn.remove.method (checkInId) ->
  check checkInId, Match.DocumentId

  # Make sure the check-in belongs to the current user.
  authorizeCheckInAction checkInId

  PAA.Practice.CheckIn.documents.remove checkInId

PAA.Practice.CheckIn.updateTime.method (checkInId, time) ->
  check checkInId, Match.DocumentId
  check time, Date

  # Make sure the check-in belongs to the current user.
  authorizeCheckInAction checkInId

  # Associate the artist with the character.
  PAA.Practice.CheckIn.documents.update checkInId,
    $set:
      time: time

PAA.Practice.CheckIn.updateText.method (checkInId, text) ->
  check checkInId, Match.DocumentId
  check text, String

  # Make sure the check-in belongs to the current user.
  authorizeCheckInAction checkInId

  # Update the text.
  PAA.Practice.CheckIn.documents.update checkInId,
    $set:
      text: text

PAA.Practice.CheckIn.updateUrl.method (checkInId, url) ->
  check checkInId, Match.DocumentId
  check url, Match.OneOf String, null

  # Make sure the check-in belongs to the current user.
  authorizeCheckInAction checkInId

  update = {}

  if url
    # See if url is already an image.
    try
      response = HTTP.get url
      contentType = response.headers['content-type']

      # Check if the url is pointing directly to an image.
      if /image/.test contentType
        # Set the image directly as an image.
        _.merge update,
          $set:
            image: {url}
          $unset:
            post: true
            video: true
            artwork: true

      else
        # We have a post so save the post url for possible linking.
        _.merge update,
          $set:
            post: {url}
          $unset:
            video: true
            artwork: true

        # Let's see if we can also extract an image from the url.
        try
          _.merge update,
            $set:
              image:
                url: PAA.Practice.CheckIn.getExternalUrlImage url

        catch exception
          _.merge update,
            $unset:
              image: true

  else
    update.$unset =
      post: true
      image: true
      video: true
      artwork: true

  PAA.Practice.CheckIn.documents.update checkInId, update

PAA.Practice.CheckIn.newMemory.method (checkInId, characterId, firstLineText) ->
  check checkInId, Match.DocumentId
  check characterId, Match.DocumentId
  check firstLineText, Match.Optional String

  # Make sure the check-in exists.
  checkIn = PAA.Practice.CheckIn.documents.findOne checkInId
  throw new AE.ArgumentException "Check-in not found." unless checkIn

  # Make sure the user controls the character that's starting the memory.
  LOI.Authorize.characterAction characterId

  # Create a new memory.
  memoryId = LOI.Memory.insert()

  # Associate the memory to this check-in.
  PAA.Practice.CheckIn.documents.update checkInId,
    $addToSet:
      memories:
        _id: memoryId

  # Create the first action in memory.
  LOI.Memory.Action.insert LOI.Memory.Actions.Say.type, characterId,
    timelineId: LandsOfIllusions.TimelineIds.Present
    locationId: Retronator.HQ.Cafe.id()
  ,
    say: text: firstLineText
  ,
    memoryId

authorizeCheckInAction = (checkInId) ->
  checkIn = PAA.Practice.CheckIn.documents.findOne checkInId
  throw new AE.ArgumentException "Check-in not found." unless checkIn

  LOI.Authorize.characterAction checkIn.character._id
