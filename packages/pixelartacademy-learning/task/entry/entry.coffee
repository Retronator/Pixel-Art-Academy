AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# An entry that is created when a character completes a task. 
class PAA.Learning.Task.Entry extends AM.Document
  @id: -> 'PixelArtAcademy.Learning.Task.Entry'
  # taskId: task ID of the task this is an entry for
  # time: the time when task was completed
  # character: character that completed the task
  #   _id
  #
  # upload: data for an upload entry
  #   picture: an image without any semantic information
  #     url: the url of the image itself
  @Meta
    name: @id()
    fields: =>
      character: @ReferenceField LOI.Character, [], true

  # Methods
  @insert: @method 'insert'

  # Subscriptions
  @forCharacter: @subscription 'forCharacter'
  @forCharacterTaskIds: @subscription 'forCharacterTaskIds'
