PAA = PixelArtAcademy
RA = Retronator.Accounts
RS = Retronator.Store
LOI = LandsOfIllusions

Yearbook = PAA.PixelBoy.Apps.Yearbook

Yearbook.students.publish ->
  collectionName = Yearbook.studentsCollectionName
  
  RA.User.documents.find(
    username: $ne: 'admin'
    characters: $exists: true
  ,
    fields:
      createdAt: true
      characters: true
      items: true
  ).observe
    added: (user) => processCharacters user, (character) => @added collectionName, character._id, character
    changed: (user) => processCharacters user, (character) => @changed collectionName, character._id, character
    removed: (user) => processCharacters user, (character) => @removed collectionName, character._id

  @ready()

processCharacters = (user, callback) ->
  return unless user.characters

  userFlags = {}

  # Class of 2016 are all who users with class of 2016 artwork, and users created before 2017 that also own alpha
  # access. This allows a user to become class of 2016 even if they later-on purchase alpha access, but they already
  # registered in 2016. It's a small trade-off so that we don't have to query individual transactions.
  hasClassOf2016Artwork = user.hasItem RS.Items.CatalogKeys.PixelArtAcademy.Kickstarter.ClassOf2016Artwork

  userFlags.hasAlphaAccess = user.hasItem RS.Items.CatalogKeys.PixelArtAcademy.AlphaAccess

  # Class of 2017 are all other backers () and players registered before 2018.
  userFlags.isBacker = false

  for key, backerItem of RS.Items.CatalogKeys.PixelArtAcademy.Kickstarter when user.hasItem backerItem
    userFlags.isBacker = true

  # Determine class year.
  if hasClassOf2016Artwork or user.createdAt < new Date(2017, 0, 1) and userFlags.hasAlphaAccess
    userFlags.classYear = 2016

  else if userFlags.isBacker or user.createdAt < new Date(2018, 0, 1)
    userFlags.classYear = 2017

  else
    userFlags.classYear = 2018

  # Determine if user is a patron.
  userFlags.isPatron = user.hasItem RS.Items.CatalogKeys.Retronator.Patreon.PatreonKeycard

  # We should show the portrait only if the user can edit avatars.
  userFlags.hasAvatarEditor = user.hasItem RS.Items.CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor

  for character in user.characters
    character = LOI.Character.documents.findOne
      _id: character._id
      # We need the avatar, otherwise we have nothing to display.
      avatar: $exists: true
    ,
      fields:
        # We only need the avatar to display in the Yearbook.
        avatar: true

    # Make sure the character isn't a bad reference.
    continue unless character

    _.extend character, userFlags

    # Process the character.
    callback character
