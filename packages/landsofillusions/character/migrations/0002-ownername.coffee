LOI = LandsOfIllusions

class Migration extends Document.AddGeneratedFieldsMigration
  name: "Adding owner name generated field."
  fields: [
    'ownerName'
  ]

LOI.Character.addMigration new Migration()
