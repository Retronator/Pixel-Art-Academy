LOI = LandsOfIllusions

class Migration extends Document.AddReferenceFieldsMigration
  name: "Adding public name to user reference field."

LOI.Character.addMigration new Migration()
