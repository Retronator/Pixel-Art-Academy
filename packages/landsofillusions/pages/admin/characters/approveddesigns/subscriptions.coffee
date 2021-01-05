LOI = LandsOfIllusions
RA = Retronator.Accounts

LOI.Pages.Admin.Characters.ApprovedDesigns.characters.publish (limit = 10, skip = 0) ->
  check limit, Match.PositiveInteger

  RA.authorizeAdmin()

  # Get character IDs from users that have the avatar editor.
  users = RA.User.documents.fetch
    'items.catalogKey': 'LandsOfIllusions.Character.Avatar.AvatarEditor'

  characterIds = for user in users
    for character in (user.characters or [])
      character._id

  characterIds = _.flatten characterIds

  # Get characters from IDs, filtering to those with an approved design.
  characters = LOI.Character.documents.fetch
    _id: $in: characterIds
    designApproved: true
    'avatar.body': $exists: true
    'avatar.outfit': $exists: true

  # Exclude characters that look like one of the pre-made characters.
  preMadeCharacters = LOI.Character.PreMadeCharacter.documents.fetch()

  preMadeBodies = []

  for preMadeCharacter in preMadeCharacters
    preMadeCharacter.character.refresh()
    preMadeBodies.push preMadeCharacter.character.avatar.body

  characterIds = []

  for character in characters
    continue if _.find preMadeBodies, (body) -> _.isEqual body, character.avatar.body

    characterIds.push character._id

  # Return the selection of relevant characters.
  LOI.Character.documents.find
    _id: $in: characterIds
  ,
    {limit, skip}
