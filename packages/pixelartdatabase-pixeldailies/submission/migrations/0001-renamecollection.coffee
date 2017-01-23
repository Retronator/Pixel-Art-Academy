AM = Artificial.Mummification
PADB = PixelArtDatabase

class Migration extends AM.RenameCollectionMigration
  name: "Renaming collection to Pixel Art Database namespace"
  old: 'PixelArtAcademyPixelDailiesSubmissions'
  new: 'PixelArtDatabase.PixelDailies.Submissions'

PADB.PixelDailies.Submission.addMigration new Migration()
