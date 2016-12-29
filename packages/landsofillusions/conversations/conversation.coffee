LOI = LandsOfIllusions

class LandsOfIllusionsConversationsConversation extends Document
  # lines: list of lines in this conversation, reverse of line.conversation
  #   _id
  #   character
  #     _id
  #     name
  #   time
  # startTime: auto-generated time of the first line in this conversation
  # endTime: auto-generated time of the last line in this conversation
  @Meta
    name: 'LandsOfIllusionsConversationsConversation'
    fields: =>
      startTime: @GeneratedField 'self', ['lines'], (conversation) ->
        return [conversation._id, undefined] unless conversation.lines?.length

        [conversation._id, conversation.lines[0].time]

      endTime: @GeneratedField 'self', ['lines'], (conversation) ->
        return [conversation._id, undefined] unless conversation.lines?.length

        [conversation._id, _.last(conversation.lines).time]

LOI.Conversations.Conversation = LandsOfIllusionsConversationsConversation
