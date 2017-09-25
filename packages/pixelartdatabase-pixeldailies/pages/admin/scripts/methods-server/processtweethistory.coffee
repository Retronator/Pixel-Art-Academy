AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.processTweetHistory': ->
    RA.authorizeAdmin()

    PADB.PixelDailies.processTweetHistory()
