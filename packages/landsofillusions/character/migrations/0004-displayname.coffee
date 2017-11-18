LOI = LandsOfIllusions

class Migration extends Document.ModifyGeneratedFieldsMigration
  name: "Update display name generated field."
  fields: [
    'displayName'
  ]

LOI.Character.addMigration new Migration()
