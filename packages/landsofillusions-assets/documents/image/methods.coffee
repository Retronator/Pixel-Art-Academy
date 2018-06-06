RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Image.insert.method (characterId, url) ->
  check characterId, Match.DocumentId
  check url, String

  LOI.Authorize.characterAction characterId

  LOI.Assets.Image.documents.insert
    url: url
    uploader:
      _id: characterId
