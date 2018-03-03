AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions
PADB = PixelArtDatabase

class PAA.Practice.Journal.Entry extends AM.Document
  @id: -> 'PixelArtAcademy.Practice.Journal.Entry'
  # time: the time when the entry was published
  # timezoneOffset: the timezone the entry was made in, in minutes UTC is ahead of this timezone
  # language: user's current language when the entry was made 
  # journal: the journal this entry appears in
  #   _id
  # [content]: array of delta operations
  #   insert: string or object to be inserted
  #     TimeHeader
  #     ----------
  #
  #     Text
  #     ----
  #     text: the text structure of the post
  #
  #     Media
  #     -------
  #     artwork: the artwork associated with the post
  #       _id
  #       image:
  #         url
  #     image: the image associated with the post
  #       url
  #     video: the video associated with the post
  #       url
  #
  #     TaskEntry
  #     ----
  #     taskEntry: the entry that describes a task being completed
  #       _id
  #
  #   attributes: object with formatting directives
  #
  # conversations: list of conversations revolving around this entry
  #   _id
  @Meta
    name: @id()
    fields: =>
      journal: @ReferenceField PAA.Practice.Journal, [], true, 'entries', []
      structure: [
        insert:
          artwork: @ReferenceField PADB.Artwork, ['image'], false
          taskEntry: @ReferenceField PAA.Learning.Task.Entry, [], false
      ]
      conversation: [@ReferenceField LOI.Conversations.Conversation]

  # Methods

  @insert: @method 'insert'
  @remove: @method 'remove'
  @updateTime: @method 'updateTime'
  @updateLanguage: @method 'updateLanguage'
  @updateContent: @method 'updateContent'

  @newConversation: @method 'newConversation'

  # Subscriptions
  @forJournalId: @subscription 'forJournalId'
  @conversationsForEntryId: @subscription 'conversationsForEntryId'
