LOI = LandsOfIllusions

class LOI.Adventure.Script
  # Load a script file.
  @load: (url) ->
    new Promise (resolve, reject) =>
      HTTP.call 'GET', url, (error, result) =>
        if error
          console.error error
          reject()
          return

        # Parse the script text into script nodes.
        scriptNodes = new @Parser(result.content).parse()
        resolve scriptNodes

  # Call on the server to prepare translations of a script
  @initialize: (id, scriptText) ->
    scriptNodes = new @Parser(scriptText).parse()

  @translate: (id, scriptNodes) ->

  @create: (options) ->
    # Work you way from end to start.
    lines = options.script.split /\r?\n/
    lines.reverse()

    nextNode = null

    for line in lines
      # Dialog is of the form "actorName: line to be said".
      dialog = line.match /\s*(.*\S)\s*:\s*(.*\S)\s*/

      if dialog
        actorName = dialog[1]
        line = dialog[2]

        nextNode = new LOI.Adventure.Script.Nodes.DialogLine options.director,
          actor: options.actors[actorName]
          line: line
          next: nextNode

        continue

    # Return nextNode which is by now the start node.
    nextNode
