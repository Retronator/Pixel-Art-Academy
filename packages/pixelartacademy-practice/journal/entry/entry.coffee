AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions
PADB = PixelArtDatabase

class PAA.Practice.Journal.Entry extends AM.Document
  @id: -> 'PixelArtAcademy.Practice.Journal.Entry'
  # journal: the journal this entry appears in
  #   _id
  #   character
  #     _id
  #     avatar
  #       fullName
  #       color
  # time: the time when the entry was created
  # order: where this entry appears in the journal
  # [content]: array of delta operations
  #   insert: string or object to be inserted
  #     timestamp: a semantic time entry
  #       time: the time to be displayed
  #       timezoneOffset: the timezone used to display the time, in minutes UTC is ahead of this timezone
  #       language: language the time is written in
  #
  #     artwork: an artwork from the pixel art database
  #       _id
  #       image:
  #         url
  #
  #     picture: an image without any semantic information
  #       url: the url of the image itself
  #       sourceWebsiteUrl: optional url from which the image was extracted, if it wasn't uploaded
  #
  #     video: a video without any semantic information
  #       url
  #
  #     task: a learning task
  #       entry: an entry created to complete the task
  #         _id
  #
  #   attributes: object with formatting directives
  #
  # action: the action representing editing of this entry (timed at last edit)
  #   _id
  # memories: list of memories revolving around this entry
  #   _id
  @Meta
    name: @id()
    fields: =>
      journal: @ReferenceField PAA.Practice.Journal, ['character'], true, 'entries', []
      structure: [
        insert:
          artwork: @ReferenceField PADB.Artwork, ['image'], false
          task:
            entry: @ReferenceField PAA.Learning.Task.Entry, [], false
      ]
      action: @ReferenceField LOI.Memory.Action, [], true, 'content.journalEntry', []
      memories: [@ReferenceField LOI.Memory, [], true, 'journalEntry', ['journal']]

  @pictureUploadContext = new PADB.Upload.Context
    name: "#{@id()}.picture"
    folder: 'check-ins'
    maxSize: 10 * 1024 * 1024 # 10 MB
    fileTypes: [
      'image/png'
      'image/jpeg'
      'image/gif'
      ]

  # Methods

  @insert: @method 'insert'
  @remove: @method 'remove'
  @updateOrder: @method 'updateOrder'
  @updateContent: @method 'updateContent'
  @replaceContent: @method 'replaceContent'

  @newMemory: @method 'newMemory'

  # Subscriptions
  @forId: @subscription 'forId'
  @forJournalId: @subscription 'forJournalId'
  @activityForCharacter: @subscription 'activityForCharacter'
  @memoriesForEntryId: @subscription 'memoriesForEntryId'
