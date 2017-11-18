PAA = PixelArtAcademy

class Migration extends Document.AddReferenceFieldsMigration
  name: "Character reference updated with new fields."

PAA.Practice.CheckIn.addMigration new Migration()
