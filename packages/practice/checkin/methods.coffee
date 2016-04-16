LOI = LandsOfIllusions
PAA = PixelArtAcademy

Meteor.methods
  'PixelArtAcademy.Practice.CheckIn.insert': (characterId, text, url, time) ->
    check characterId, Match.DocumentId
    check text, Match.OptionalOrNull String
    check url, Match.OptionalOrNull String
    check time, Match.OptionalOrNull Date

    # Make sure the character belongs to the current user.
    authorizeCharacter characterId

    # We create a new check-in for the given character.
    checkIn =
      time: time or new Date()
      character:
        _id: characterId

    checkIn.text = text if text

    if url
      # See if url is already an image.
      try
        response = HTTP.get url
        contentType = response.headers['content-type']

        # Check if the url is pointing directly to an image.
        if /image/.test contentType
          # Set the image directly as an image.
          checkIn.image =
            url: url

        else
          # We have a post so save the post url for possible linking.
          checkIn.post =
            url: url

          # Let's see if we can also extract an image from the url.
          try
            checkIn.image =
              url: Meteor.call 'PixelArtAcademy.Practice.CheckIn.getExternalUrlImage', url

    PAA.Practice.CheckIn.documents.upsert
      time: checkIn.time
      'character._id': checkIn.character._id
    ,
      checkIn

  'PixelArtAcademy.Practice.CheckIn.changeText': (checkInId, newText) ->
    check checkInId, Match.DocumentId
    check newText, String

    # Make sure the check-in belongs to the current user.
    authorizeCheckIn checkInId

    # Associate the artist with the character.
    PAA.Practice.CheckIn.documents.update checkInId,
      $set:
        text: newText

  'PixelArtAcademy.Practice.CheckIn.remove': (checkInId) ->
    check checkInId, Match.Optional Match.DocumentId

    # Make sure the check-in belongs to the current user.
    authorizeCheckIn checkInId

    PAA.Practice.CheckIn.documents.remove checkInId

authorizeCharacter = (characterId) ->
  currentUserId = Meteor.userId()

  # You need to be logged-in to perform actions with the character.
  throw new Meteor.Error 'unauthorized', "Unauthorized." unless currentUserId

  character = LOI.Accounts.Character.documents.findOne characterId
  throw new Meteor.Error 'not-found', "Character not found." unless character

  throw new Meteor.Error 'unauthorized', "Unauthorized." unless character.user._id is currentUserId

authorizeCheckIn = (checkInId) ->
  checkIn = PAA.Practice.CheckIn.documents.findOne checkInId
  throw new Meteor.Error 'not-found', "Character not found." unless checkIn

  authorizeCharacter checkIn.character._id
