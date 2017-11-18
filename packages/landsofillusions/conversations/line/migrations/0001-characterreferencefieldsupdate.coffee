LOI = LandsOfIllusions

class Migration extends Document.AddReferenceFieldsMigration
  name: "Character reference updated with new fields."

LOI.Conversations.Line.addMigration new Migration()
