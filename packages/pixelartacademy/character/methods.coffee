LOI = LandsOfIllusions
PAA = PixelArtAcademy

Meteor.methods
  'characterCreateArtist': (characterId) ->
    check characterId, Match.DocumentId

    character = LOI.Character.documents.findOne characterId
    throw new Meteor.Error 'not-found', "Character not found." unless character

    # Make sure the character belongs to the logged in user.
    currentUserId = Meteor.userId()
    throw new Meteor.Error 'unauthorized', "Unauthorized." unless currentUserId is character.user._id or Roles.userIsInRole currentUserId, 'admin'

    # We create a new artist for the given character.
    Artist.documents.insert Artist.defaultData()

  'characterClaimArtist': (characterId, artistId, claimCode) ->
    check characterId, Match.DocumentId
    check artistId, Match.DocumentId
    check claimId, Match.OptionalOrNull Match.DocumentId

    character = LOI.Character.documents.findOne characterId
    throw new Meteor.Error 'not-found', "Character not found." unless character

    artist = PAA.Artworks.Artist.documents.findOne characterId
    throw new Meteor.Error 'not-found', "Artist not found." unless artist

    # If we have a claim code simply compare it to the one on the character.
    if claimCode
      throw new Meteor.Error 'invalid-argument', "Claim code does not match." unless artist.claimCode is claimCode

    else
      # See if the artist
      throw new Meteor.Error 'unauthorized', "." unless artist.matchesServices Meteor.user().services

    # Associate the artist with the character.
    PAA.Artworks.Artist.documents.update artistId,
      $set:
        'character._id': characterId

