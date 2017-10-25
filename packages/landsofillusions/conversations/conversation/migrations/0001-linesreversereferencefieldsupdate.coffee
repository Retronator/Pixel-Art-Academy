LOI = LandsOfIllusions

class Migration extends Document.AddReferenceFieldsMigration
  name: "Lines reverse reference updated with new fields."

LOI.Conversations.Conversation.addMigration new Migration()
