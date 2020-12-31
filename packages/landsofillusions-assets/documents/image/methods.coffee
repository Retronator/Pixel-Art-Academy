RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Image.insert.method (characterId, url) ->
  check characterId, Match.OptionalOrNull Match.DocumentId
  check url, String

  if characterId
    LOI.Authorize.characterAction characterId

  else
    LOI.Authorize.admin()

  LOI.Assets.Image.documents.insert
    url: url
    uploader:
      _id: characterId
