LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Intercom extends LOI.Adventure.Scene
  @id: -> 'Retronator.HQ.Items.Intercom'
  @timelineId: -> PAA.TimelineIds.RealLife

  @location: ->
    # Intercom is present everywhere the region includes it.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/items/intercom/intercom.script'

  constructor: ->
    super

    @_scheduleNextMessage delay: 1000

    @_pixelDailiesSubscription = PADB.PixelDailies.Pages.Home.themes.subscribe 2

  destroy: ->
    super

    Meteor.clearTimeout @_nextMessageTimeout

    @_pixelDailiesSubscription.stop()

  _scheduleNextMessage: (options = {}) ->
    # Play next message in a minute or two.
    options.delay ?= (1 + Math.random()) * 600

    @_nextMessageTimeout = Meteor.setTimeout =>
      # Don't play the message if the user is busy doing something.
      busyConditions = [
        not LOI.adventure.interface.active()
        LOI.adventure.interface.waitingKeypress()
        LOI.adventure.interface.commandInput.command().length
        LOI.adventure.interface.showDialogSelection()
      ]
      
      if _.some busyConditions
        # Retry in 10 seconds.
        @_scheduleNextMessage delay: 1000
        return

      # Looks OK, say something funny!
      @_playMessage()

      @_scheduleNextMessage()
    ,
      options.delay

  _playMessage: ->
    script = @listeners[0].script

    options = [
      # Current Pixel Dailies
      weight: 1
      function: =>
        [themesCursor, submissionsCursor] = PADB.PixelDailies.Pages.Home.themes.query 1

        latestTheme = themesCursor.fetch()[0]
        script.ephemeralState().pixelDailiesHashtag = latestTheme.hashtags[0]

        script.startNode.labels.CurrentPixelDailies
    ,
      # Yesterday's Pixel Dailies
      weight: 1
      function: =>
        [themesCursor, submissionsCursor] = PADB.PixelDailies.Pages.Home.themes.query 2

        yesterdayTheme = themesCursor.fetch()[1]
        console.log yesterdayTheme
        topSubmission = yesterdayTheme.topSubmissions[0]

        _.extend script.ephemeralState(),
          pixelDailiesHashtag: yesterdayTheme.hashtags[0]
          pixelDailiesUser: topSubmission.user.name
          pixelDailiesFavorites: topSubmission.favoritesCount

        script.startNode.labels.YesterdaysPixelDailies
    ,
      weight: 1
      function: =>
        # Transaction Message
        console.log "Transaction"
    ]

    # If there was a new customer in the last 10 minutes (and we haven't said it yet), add that as a very strong option.
    options.push
      weight: 1
      function: =>
        console.log "New customer"

    totalWeight = _.sum _.map options, 'weight'
    randomValue = Math.random() * totalWeight

    for option in options
      randomValue -= option.weight
      if randomValue < 0
        # Execute this option.
        scriptNode = option.function()
        break

    return unless scriptNode

    # Rewire intro dialog node to point to our selection.
    introDialogNode = script.startNode.labels.Intro.next
    introDialogNode.next = scriptNode

    LOI.adventure.director.startNode introDialogNode

  # Script

  initializeScript: ->
    @setThings @options.listener.avatars

  # Listener

  @avatars: ->
    burra: PAA.Cast.Burra
    retro: PAA.Cast.Retro
