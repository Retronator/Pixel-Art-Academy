LOI = LandsOfIllusions
PAA = PixelArtAcademy

Meteor.methods
  practiceCheckIn: (characterId, text, imageUrl) ->
    check characterId, Match.DocumentId
    check text, String
    check imageUrl, String

    # Make sure the character belongs to the current user.
    authorizeCharacter characterId

    # We create a new artist for the given character.
    PAA.Practice.CheckIn.documents.insert
      time: new Date()
      character:
        _id: characterId
      text: text
      image:
        url: imageUrl

  practiceCheckInChangeText: (checkInId, newText) ->
    check checkInId, Match.DocumentId
    check newText, String

    # Make sure the check-in belongs to the current user.
    authorizeCheckIn checkInId

    # Associate the artist with the character.
    PAA.Practice.CheckIn.documents.update checkInId,
      $set:
        text: newText

  practiceCheckInRemove: (checkInId) ->
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
