LOI = LandsOfIllusions

class Migration extends Document.AddReferenceFieldsMigration
  name: "Template name and description have embedded translations."

LOI.Character.Part.Template.addMigration new Migration()
