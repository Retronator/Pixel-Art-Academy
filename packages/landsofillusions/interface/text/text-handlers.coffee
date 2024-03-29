AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Interface.Text extends LOI.Interface.Text
  initializeHandlers: ->
    # Listen for command input changes.
    @autorun (computation) =>
      @commandInput.command()
      @onCommandInputChanged()

    # Pause dialog selection when we're waiting for a key press ourselves.
    @autorun (computation) =>
      @dialogueSelection.paused @waitingKeypress()

    @_currentIntroductionFunction = new ReactiveField null

  prepareForLocationChange: (newLocation, complete) =>
    @_animateLoadingCover 100, complete

  _animateLoadingCover: (heightPercentage, complete) =>
    illustrationHeight = @illustrationSize.height()

    @$locationLoadingCover.velocity('stop').velocity
      height: "#{heightPercentage}%"
    ,
      easing: 'easeInOutQuart'
      duration: Math.sqrt(illustrationHeight) * 40
      complete: => complete?()

  onLocationChanged: ->
    location = @location()

    # Wait for narrative to be created and location to load.
    @autorun (computation) =>
      return unless @isCreated()
      return unless location.ready()
      computation.stop()

      # Initialize introduction function after location has changed and new listeners have been created.
      Tracker.nonreactive => @initializeIntroductionFunction()

      # If we've been here before, just start with a fresh narrative. This is the persistent visited, not the
      # per-session one, since we want to do the intro only when it's really the first time to see the location.
      if location.state 'visited'
        @narrative.clear()

      else
        # We haven't been here yet, so completely reset the interface into intro mode.
        @reset()

      # We have cleared the interface so it can now start processing any scripts.
      @locationChangeReady true

      # Wait one frame so that any script nodes are processed. Then we can
      # see if the interface is empty, or it is already paused on something.
      Meteor.setTimeout =>
        @narrative.addText "What do you want to do?", scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.None unless @waitingKeypress()
  
        # All the texts have been loaded from the DB at this point.
        # Wait for all the reactivity to finish reflowing the page.
        Meteor.setTimeout =>
          @resize()

          # Set scroll position to reveal the top or the bottom of the UI.
          scrollPosition = if location.constructor.visited() then @maxScrollTop() else 0
          @scroll position: scrollPosition

          # Show loading text if location loading takes too long.
          @_locationLoadingCaptionTimeout = Meteor.setTimeout =>
            @$locationLoadingCaption.css(display: 'block').addClass('visible')
          ,
            1500

          # Wait for location illustration to be ready.
          Tracker.autorun (computation) =>
            return unless LOI.adventure.world.sceneManager()?.sceneItemsReady()
            computation.stop()

            Meteor.clearTimeout @_locationLoadingCaptionTimeout
            @$locationLoadingCaption.css(display: 'none').removeClass('visible')

            @_animateLoadingCover 0
        ,
          0
      ,
        0

  initializeIntroductionFunction: ->
    # Wait for new enter responses.
    Tracker.autorun (computation) =>
      return unless responseResults = LOI.adventure.locationOnEnterResponseResults()
      computation.stop()
      
      # Set the new introduction function, if it was set by any of the listeners.
      @_currentIntroductionFunction null

      for result in responseResults
        introductionFunction = result.enterResponse.introductionFunction()

        if introductionFunction
          @_currentIntroductionFunction introductionFunction

          # Force user to read the custom introduction.
          @showIntro()

  onCommandInputEnter: ->
    # Stop intro on enter.
    if @inIntro()
      @stopIntro()
      return

    # After intro is stopped, enter resumes dialogs.
    if pausedLineNode = @_pausedNode()
      # Clear the paused node and handle it. Use the force flag since the node has already been marked as handled.
      @_pausedNode null
      @_handleNode pausedLineNode, force: true

      # Clear the command input in case it accumulated any text in the mean time.
      @commandInput.clear()
      return

    # At this point, enter confirms the command that has been entered.
    @_executeCommand @hoveredCommand() or @commandInput.command().trim()

    # Scroll to bottom on enter.
    @narrative.scroll()

  _executeCommand: (command) ->
    return unless command?.length

    # Add closing quote if needed.
    numberOfQuotes = _.sumBy command, (character) => if character is '"' then 1 else 0
    command += '"' if numberOfQuotes % 2

    @narrative.addText "> #{command.toUpperCase()}"
    LOI.adventure.parser.parse command
    @commandInput.confirm command

  onCommandInputChanged: ->
    # Scroll to bottom to reveal new command.
    @narrative.scroll()
    
  onDialogueSelectionEnter: ->
    # Continue with the selection.
    @dialogueSelection.confirm()
