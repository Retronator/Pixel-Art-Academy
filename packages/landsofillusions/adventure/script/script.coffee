LOI = LandsOfIllusions

class LOI.Adventure.Script
  @create: (options) ->
    # Work you way from end to start.
    lines = options.script.split /\r?\n/
    lines.reverse()

    nextNode = null

    for line in lines
      dialog = line.match /\s*(.*\S)\s*:\s*(.*\S)\s*/

      if dialog
        actorName = dialog[1]
        line = dialog[2]

        nextNode = new LOI.Adventure.Script.Nodes.DialogLine options.director,
          actor: options.actors[actorName]
          line: line
          next: nextNode

        continue

    # Return the nextNode which is the start node.
    nextNode
