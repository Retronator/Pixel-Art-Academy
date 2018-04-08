LOI = LandsOfIllusions
AM = Artificial.Mummification

Nodes = LOI.Adventure.Script.Nodes

class LOI.Memory.Actions.Say extends LOI.Memory.Action
  # content:
  #   say: character says something
  #     text: the text being said
  @type: 'LandsOfIllusions.Memory.Actions.Say'
  @register @type, @

  @registerContentPattern @type,
    say:
      text: String

  @activeDescription: ->
    "_person_ is talking."

  start: (person) ->
    # Create a dialog node.
    dialogueLine = new Nodes.DialogueLine
      line: @content.say.text
      actor: person

    LOI.adventure.director.startNode dialogueLine
