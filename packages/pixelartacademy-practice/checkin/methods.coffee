LOI = LandsOfIllusions
PAA = PixelArtAcademy

Meteor.methods
  'PixelArtAcademy.Practice.CheckIn.insert': (characterId, text, url, time) ->
    check characterId, Match.DocumentId
    check text, Match.OptionalOrNull String
    check url, Match.OptionalOrNull String
    check time, Match.OptionalOrNull Date

    # Make sure the user can perform this character action.
    LOI.Authorize.characterAction characterId

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
    authorizeCheckInAction checkInId

    # Associate the artist with the character.
    PAA.Practice.CheckIn.documents.update checkInId,
      $set:
        text: newText

  'PixelArtAcademy.Practice.CheckIn.remove': (checkInId) ->
    check checkInId, Match.Optional Match.DocumentId

    # Make sure the check-in belongs to the current user.
    authorizeCheckInAction checkInId

    PAA.Practice.CheckIn.documents.remove checkInId

  'PixelArtAcademy.Practice.CheckIn.newConversation': (checkInId, characterId, firstLineText) ->
    check checkInId, Match.Optional Match.DocumentId

    # Make sure the check-in exists.
    checkIn = PAA.Practice.CheckIn.documents.findOne checkInId
    throw new Meteor.Error 'not-found', "Check-in not found." unless checkIn

    # Make sure the user controls the character that's starting the conversation.
    LOI.Authorize.characterAction characterId

    # Create a new conversation.
    conversationId = Random.id()
    Meteor.call 'LandsOfIllusions.Conversations.Conversation.insert', conversationId

    # Associate the conversation to this check-in.
    PAA.Practice.CheckIn.documents.update checkInId,
      $addToSet:
        conversations: conversationId

    # Create the first line of conversation.
    Meteor.call 'LandsOfIllusions.Conversations.Line.insert', conversationId, characterId, firstLineText

authorizeCheckInAction = (checkInId) ->
  checkIn = PAA.Practice.CheckIn.documents.findOne checkInId
  throw new Meteor.Error 'not-found', "Check-in not found." unless checkIn

  LOI.Authorize.characterAction checkIn.character._id
