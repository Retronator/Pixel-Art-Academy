LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Conversations.Line extends AM.Document
  @id: -> 'LandsOfIllusions.Conversations.Line'
  # conversation: which conversation this line belongs to.
  #   _id
  # character: character who said this line
  #   _id
  #   avatar
  #     fullName
  #     color
  # text: what was said in this line
  # time: when this line was said
  @Meta
    name: @id()
    fields: =>
      conversation: @ReferenceField LOI.Conversations.Conversation, [], true, 'lines', ['character', 'text', 'time']
      character: @ReferenceField LOI.Character, ['avatar.fullName', 'avatar.color'], false

  # Methods

  @insert: @method 'insert'
  @changeText: @method 'changeText'

  # Subscriptions

  @forConversation: @subscription 'forConversation'
