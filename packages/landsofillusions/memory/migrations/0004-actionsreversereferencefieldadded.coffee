LOI = LandsOfIllusions

class Migration extends Document.AddReferenceFieldsMigration
  name: "Actions reverse reference added."

LOI.Memory.addMigration new Migration()
