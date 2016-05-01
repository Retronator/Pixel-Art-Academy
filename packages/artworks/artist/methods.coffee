LOI = LandsOfIllusions
PAA = PixelArtAcademy
Artist = PAA.Artworks.Artist

Meteor.methods
  artistInsert: (artistId) ->
    check artistId, Match.Optional Match.DocumentId
    LOI.Authorize.admin()

    # We create a new artist for the given character.
    Artist.documents.insert Artist.defaultData()

  artistSetCharacter: (artistId, characterId) ->
    check characterId, Match.DocumentId
    check artistId, Match.DocumentId
    LOI.Authorize.admin()

    # Associate the artist with the character.
    Artist.documents.update artistId,
      $set:
        'character._id': characterId

  artistUpdate: (artistId, update, options) ->
    check artistId, Match.DocumentId
    check update, Object
    check options, Match.Optional Object
    LOI.Authorize.admin()

    Artist.documents.update artistId, update, options

  artistRemove: (artistId) ->
    check artistId, Match.Optional Match.DocumentId
    LOI.Authorize.admin()

    Artist.documents.remove artistId
