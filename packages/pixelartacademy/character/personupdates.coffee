LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PersonUpdates extends LOI.Adventure.Listener
  @id: -> "PixelArtAcademy.PersonUpdates"

  @scriptUrls: -> [
    'retronator_pixelartacademy/character/personupdates.script'
  ]
  
  class @Script extends LOI.Adventure.Script
    @id: -> "PixelArtAcademy.PersonUpdates"
    @initialize()
  
    initialize: ->
      @setCallbacks
        WaitToLoad: (complete) =>
          Tracker.autorun (computation) =>
            return if @actionsSubscription and not @actionsSubscription.ready()
            computation.stop()

            complete()
          
  @initialize()

  onScriptsLoaded: ->
    @script = @scripts[@constructor.Script.id()]

  getScript: (options) ->
    # Set person.
    @script.setThings person: options.person

    # Set the node we should transition back to after this script is done.
    @script.startNode.labels.End.next = options.nextNode

    # Save the actions subscription to script so we can query it.
    @script.actionsSubscription = options.actionsSubscription

    # Find the actions this person made since earliest time.
    actions = options.person.recentActions options.earliestTime.time, options.earliestTime.gameTime

    # TODO: Load actions into ephemeral state.
    
    @script
