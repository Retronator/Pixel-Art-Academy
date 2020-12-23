PAA = PixelArtAcademy

class Migration extends Document.AddReferenceFieldsMigration
  name: "Add user and character names to entries."

PAA.Learning.Task.Entry.addMigration new Migration()
