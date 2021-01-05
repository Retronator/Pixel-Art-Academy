LOI = LandsOfIllusions

class Migration extends Document.AddReferenceFieldsMigration
  name: "Adding character's designApproved reverse field to user."

LOI.Character.addMigration new Migration()
