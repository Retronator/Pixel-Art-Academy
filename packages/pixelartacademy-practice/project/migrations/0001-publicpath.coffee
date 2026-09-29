PAA = PixelArtAcademy

class Migration extends Document.RenameFieldsMigration
  name: "Rename project name into publicPath."
  fields:
    name: 'publicPath'

PAA.Practice.Project.addMigration new Migration()
