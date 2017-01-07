PAA = PixelArtAcademy

class Migration extends Document.RenameFieldsMigration
  name: "Rename theme date to actual time."
  fields:
    date: 'time'

PAA.PixelDailies.Theme.addMigration new Migration()
