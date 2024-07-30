AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get all projects for admin purposes.
PAA.Practice.Project.all.publish ->
  RA.authorizeAdmin()
  
  PAA.Practice.Project.documents.find()

# Get projects for a certain character.
PAA.Practice.Project.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  PAA.Practice.Project.documents.find
    'characters._id': characterId
