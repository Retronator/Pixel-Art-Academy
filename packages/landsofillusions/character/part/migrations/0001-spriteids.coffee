LOI = LandsOfIllusions

class Migration extends Document.AddGeneratedFieldsMigration
  name: "Adding spriteIds generated array."
  fields: [
    'spriteIds'
  ]

LOI.Character.Part.Template.addMigration new Migration()
