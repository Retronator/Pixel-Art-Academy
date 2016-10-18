LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Construct
  constructor: ->
    RA.addPublicPage 'LandsOfIllusions.Construct', '/construct', 'LandsOfIllusions.Construct.Pages.Login'

    RA.addUserPage 'LandsOfIllusions.Construct.Start', '/construct/start', 'LandsOfIllusions.Construct.Pages.Account'
    RA.addUserPage 'LandsOfIllusions.Construct.Characters', '/construct/characters', 'LandsOfIllusions.Construct.Pages.Account'
