AE = Artificial.Everywhere
PAA = PixelArtAcademy

class PAA.Learning.Task.Automatic extends PAA.Learning.Task
  @type = 'Automatic'

  # Override if the task can be automatically determined if it was completed.
  @completedConditions: -> throw new AE.NotImplementedException "Automatic tasks must provide conditions for completion."
  completedConditions: -> @constructor.completedConditions()
