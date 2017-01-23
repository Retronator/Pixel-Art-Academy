PADB = PixelArtDatabase

class Migration extends Document.RenameFieldsMigration
  name: "Rename theme date to actual time."
  fields:
    date: 'time'

PADB.PixelDailies.Theme.addMigration new Migration()
