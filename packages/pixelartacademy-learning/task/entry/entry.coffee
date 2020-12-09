AM = Artificial.Mummification
RA = Retronator.Accounts
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# An entry that is created when a character completes a task.
# Note that these are public documents and should contain no sensitive information.
class PAA.Learning.Task.Entry extends AM.Document
  @id: -> 'PixelArtAcademy.Learning.Task.Entry'
  # taskId: task ID of the task this is an entry for
  # time: the time when task was completed
  # user: user that completed the task, or null if a character did it
  #   _id
  # character: character that completed the task, or null if a user did it
  #   _id
  # action: the action representing completion of this task, or null if a user did it
  #   _id
  #
  # upload: data for an upload entry
  #   picture: an image without any semantic information
  #     url: the url of the image itself
  #
  # survey: data for a survey entry
  #   {questionKey}: answer data for the given question, depending on question type
  @Meta
    name: @id()
    fields: =>
      user: Document.ReferenceField RA.User, [], true
      character: Document.ReferenceField LOI.Character, [], true
      action: Document.ReferenceField LOI.Memory.Action, [], true, 'content.taskEntry', ['taskId']

  # Methods
  @insert: @method 'insert'
  @insertForUser: @method 'insertForUser'

  # Subscriptions
  @forCurrentUser: @subscription 'forCurrentUser'
  @forCharacter: @subscription 'forCharacter'
  @recentForCharacter: @subscription 'recentForCharacter'
  @forCharacterTaskIds: @subscription 'forCharacterTaskIds'
  @forCharactersTaskId: @subscription 'forCharactersTaskId'
