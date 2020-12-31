LOI = LandsOfIllusions

class LOI.Adventure.Scene.ConversationBranch extends LOI.Adventure.Scene
  @returnLabel: -> # Override to provide the label in the calling script to return to.

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCallbacks
      Return: (complete) =>
        # Return back to the calling script.
        LOI.adventure.director.startScript @_returnScript, label: scene.constructor.returnLabel()
        complete()

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    # Save the script so we know where to return to.
    @script._returnScript = choicePlaceholderResponse.script
