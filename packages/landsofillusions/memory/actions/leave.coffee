LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Memory.Actions.Leave extends LOI.Memory.Action
  # Leave is a dummy action constructed locally to indicate a character leaving.
  @type: 'LandsOfIllusions.Memory.Actions.Leave'
  @register @type, @

  @startDescription: ->
    "_person_ leaves."
