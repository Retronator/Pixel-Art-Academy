AE = Artificial.Everywhere
RA = Retronator.Accounts
PADB = PixelArtDatabase

Meteor.methods
  'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts.updateThemeSubmissions': ->
    RA.authorizeAdmin()

    themes = PADB.PixelDailies.Theme.documents.find(
      processingError:
        $exists: false
    ).fetch()

    console.log "Updating top submissions on themes. Total:", themes.length

    count = 0

    for theme in themes
      PADB.PixelDailies.Theme.updateSubmissions theme._id
      count++

    console.log "#{count} themes were successfully updated."
