LOI = LandsOfIllusions

class LandsOfIllusionsConversationsLine extends Document
  # conversation: which conversation this line belongs to.
  #   _id
  # character: character who said this line
  #   _id
  #   name
  #   color
  # text: what was said in this line
  # time: when this line was said
  @Meta
    name: 'LandsOfIllusionsConversationsLine'
    fields: =>
      conversation: @ReferenceField LOI.Conversations.Conversation, [], true, 'lines', ['character', 'time']
      character: @ReferenceField LOI.Accounts.Character, ['name', 'color'], false

LOI.Conversations.Line = LandsOfIllusionsConversationsLine
