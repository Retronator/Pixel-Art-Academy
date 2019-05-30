LOI = LandsOfIllusions
RA = Retronator.Accounts

LOI.Pages.Admin.Characters.ApprovedDesigns.characters.publish (limit = 10, skip = 0) ->
  check limit, Match.PositiveInteger

  RA.authorizeAdmin()

  LOI.Character.documents.find
    designApproved: true
  ,
    {limit, skip}
