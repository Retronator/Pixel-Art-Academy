AM = Artificial.Mummification
PADB = PixelArtDatabase

class Migration extends AM.RenameCollectionMigration
  name: "Renaming collection to Pixel Art Database namespace"
  old: 'PixelArtAcademyPixelDailiesThemes'
  new: 'PixelArtDatabase.PixelDailies.Themes'

PADB.PixelDailies.Theme.addMigration new Migration()
