AM = Artificial.Mummification
RA = Retronator.Accounts
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# An entry that is created when a character completes a task.
# Note that these are public documents and should contain no sensitive information.
class PAA.Learning.Task.Entry extends AM.Document
  @id: -> 'PixelArtAcademy.Learning.Task.Entry'
  # profileId: the profile that completed the task
  # lastEditTime: the time when task was completed
  # taskId: task ID of the task this is an entry for
  # action: the action representing completion of this task
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
      user: Document.ReferenceField RA.User, ['publicName'], true
      character: Document.ReferenceField LOI.Character, ['avatar.fullName'], true
      action: Document.ReferenceField LOI.Memory.Action, [], true, 'content.taskEntry', ['taskId']
      
  @enablePersistence()

  # Methods
  @insert: @method 'insert'
  @insertForUser: @method 'insertForUser'
  @remove: @method 'remove'
  @removeForUser: @method 'removeForUser'

  # Subscriptions
  @forCurrentUser: @subscription 'forCurrentUser'
  @forCharacter: @subscription 'forCharacter'
  @recentForCharacter: @subscription 'recentForCharacter'
  @activityForCharacter: @subscription 'activityForCharacter'
  @forCharacterTaskIds: @subscription 'forCharacterTaskIds'
  @forCharactersTaskId: @subscription 'forCharactersTaskId'
  @forTaskId: @subscription 'forTaskId'
  
  @create: (profileId, situation, taskId, data) ->
    # Make sure we don't already have an entry for this task. This should not
    # raise an exception since the client might not have received the entry yet.
    existing = PAA.Learning.Task.Entry.documents.findOne
      profileId: profileId
      taskId: taskId
    
    return if existing
    
    entry = _.extend
      profileId: profileId
      lastEditTime: new Date()
      taskId: taskId
    ,
      data
    
    ###
    actionId = LOI.Memory.Action.do PAA.Learning.Task.Entry.Action.type, characterId, situation, {}
    
    entry.action =
      _id: actionId
    ###
  
    PAA.Learning.Task.Entry.documents.insert entry
