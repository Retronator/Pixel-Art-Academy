LOI = LandsOfIllusions
RA = Retronator.Accounts
RS = Retronator.Store

LOI.Pages.Admin.GroupPhoto.characters.publish ->
  RA.authorizeAdmin()

  #transactions = RS.Transaction.documents.fetch
  #  'payments.type': 'PatreonPledge'

  #emails = _.uniq (transaction.email for transaction in transactions)

  #users = RA.User.documents.fetch
  #  'registered_emails.address': $in: emails

  users = RA.User.documents.fetch
    'items.catalogKey': 'LandsOfIllusions.Character.Avatar.AvatarEditor'

  characterIds = for user in users
    for character in (user.characters or [])
      character._id

  characterIds = _.flatten characterIds

  console.log "Found #{characterIds.length} characters from #{users.length} users."

  characters = LOI.Character.documents.fetch
    _id: $in: characterIds
    'avatar.body': $exists: true
    'avatar.outfit': $exists: true

  console.log "Query filtered to #{characters.length} characters."

  preMadeCharacters = LOI.Construct.Loading.PreMadeCharacter.documents.fetch()

  bodies = []

  for preMadeCharacter in preMadeCharacters
    preMadeCharacter.character.refresh()
    bodies.push preMadeCharacter.character.avatar.body

  characterIds = []

  for character in characters
    continue if _.find bodies, (body) -> _.isEqual body, character.avatar.body

    characterIds.push character._id

  console.log "Manually filtered to #{characterIds.length} characters."

  LOI.Character.documents.find
    _id: $in: characterIds
  ,
    limit: 130
