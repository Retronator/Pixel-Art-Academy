LOI = LandsOfIllusions

class Migration extends Document.AddReferenceFieldsMigration
  name: "Lines reverse reference updated with new fields."

LOI.Memory.addMigration new Migration()
