LOI = LandsOfIllusions

class LOI.Character.Behavior.FocalPoints
  @Names:
    Sleep: 'Sleep'
    Job: 'Job'
    School: 'School'
    Drawing: 'Drawing'

  constructor: (@behavior) ->
    @property = @behavior.part.properties.focalPoints
