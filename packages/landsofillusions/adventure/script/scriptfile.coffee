LOI = LandsOfIllusions

# Script file represents a .script file that can include multiple scripts (root Script nodes).
# The class creates a promise that gets fulfilled when the file has been successfully loaded and parsed.
class LOI.Adventure.ScriptFile
  constructor: (@options) ->
    @scripts = {}

    @promise = new Promise (resolve, reject) =>
      # The script file can be given the text directly or just an URL that needs to be loaded.
      if @options.text
        @_processText @options.text, resolve
        
      else if @options.url
        @_load @options.url, resolve, reject

  # Load a script file.
  _load: (url, resolve, reject) ->
    HTTP.call 'GET', url, (error, result) =>
      if error
        console.error error
        reject()
        return

      # Parse the script text into script nodes.
      @_processText result.content, resolve
      
  _processText: (scriptText, resolve) ->
    parser = new @constructor.Parser scriptText

    for id, node of parser.scriptNodes
      constructor = LOI.Adventure.Script.getClassForId id
      console.error "Script", id, "missing." unless constructor

      @scripts[id] = new constructor
        startNode: node
        listener: @options.listener
        parent: @options.listener?.options.parent

    # Return the script file.
    resolve @
