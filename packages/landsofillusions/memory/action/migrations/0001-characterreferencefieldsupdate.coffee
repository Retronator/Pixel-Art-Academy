LOI = LandsOfIllusions

class Migration extends Document.AddReferenceFieldsMigration
  name: "Character reference updated with new fields."

LOI.Memory.Action.addMigration new Migration()
