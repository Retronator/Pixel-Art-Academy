PAA = PixelArtAcademy
RA = Retronator.Accounts
RS = Retronator.Store
LOI = LandsOfIllusions

Yearbook = PAA.PixelBoy.Apps.Yearbook

Yearbook.classOf2016.publish ->
  collectionName = Yearbook.classOf2016CharactersCollectionName
  
  # Class of 2016 are all who users with class of 2016 artwork, and users created before 2017 that also own alpha
  # access. This allows a user to become class of 2016 even if they later-on purchase alpha access, but they already
  # registered in 2016. It's a small trade-off so that we don't have to query individual transactions.
  RA.User.documents.find(
    $or: [
      'items.catalogKey': RS.Items.CatalogKeys.PixelArtAcademy.Kickstarter.ClassOf2016Artwork
    ,
      createdAt: $lt: new Date(2017, 0, 1)
      'items.catalogKey': RS.Items.CatalogKeys.PixelArtAcademy.AlphaAccess
    ]
  ,
    fields:
      # We only need to get a list of characters.
      characters: true
  ).observe
    added: (user) => processCharacters user, (character) => @added collectionName, character._id, character
    changed: (user) => processCharacters user, (character) => @changed collectionName, character._id, character
    removed: (user) => processCharacters user, (character) => @removed collectionName, character._id

  @ready()

processCharacters = (user, callback) ->
  return unless user.characters

  for character in user.characters
    character = LOI.Character.documents.findOne
      _id: character._id
      # We need the avatar, otherwise we have nothing to display.
      avatar: $exists: true
    ,
      fields:
        # We only need the avatar to display in the Yearbook.
        avatar: true

    # Process the character, but make sure the character link is not stale.
    callback character if character
