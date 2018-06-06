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
  #   avatar
  #     fullName
  @Meta
    name: @id()
    fields: =>
      character: @ReferenceField LOI.Character, ['avatar.fullName'], true
