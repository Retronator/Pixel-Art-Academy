LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Construct
  constructor: ->
    RA.addPublicPage 'LandsOfIllusions', '/landsofillusions', 'LandsOfIllusions.Construct.Pages.Login'

    RA.addUserPage 'LandsOfIllusions.Start', '/landsofillusions/start', 'LandsOfIllusions.Construct.Pages.Account'
    RA.addUserPage 'LandsOfIllusions.Characters', '/landsofillusions/characters', 'LandsOfIllusions.Construct.Pages.Account'
