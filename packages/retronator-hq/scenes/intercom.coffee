LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Scenes.Intercom extends LOI.Adventure.Scene
  @id: -> 'Retronator.HQ.Scenes.Intercom'
  @timelineId: -> LOI.TimelineIds.RealLife

  @location: ->
    # Intercom is present everywhere the region includes it.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/scenes/intercom.script'

  constructor: ->
    super

    @_scheduleNextMessage()

    PADB.PixelDailies.Pages.Home.themes.subscribe @, 2

    @subscribe RS.Transaction.messages, 20

  destroy: ->
    super

    Meteor.clearTimeout @_nextMessageTimeout

  _scheduleNextMessage: (options = {}) ->
    # Play next message in a minute or two.
    options.delay ?= (1 + Math.random()) * 60 * 1000

    @_nextMessageTimeout = Meteor.setTimeout =>
      if LOI.adventure.interface.busy() or LOI.adventure.currentContext()
        # Retry in 10 seconds.
        @_scheduleNextMessage delay: 10000
        return

      # Looks OK, say something funny!
      @_playMessage()

      # Wait for message to play.
      Meteor.setTimeout =>
        Tracker.autorun (computation) =>
          return if LOI.adventure.interface.busy()
          computation.stop()

          # Continue to next.
          @_scheduleNextMessage()
      ,
        0
    ,
      options.delay

  _playMessage: ->
    script = @listeners[0].script

    messages = {}

    # Current Pixel Dailies
    messages.CurrentPixelDailies =
      weight: 1
      function: =>
        [themesCursor, submissionsCursor] = PADB.PixelDailies.Pages.Home.themes.query 1

        latestTheme = themesCursor.fetch()[0]
        return unless latestTheme?.hashtags?.length

        script.ephemeralState().pixelDailiesHashtag = latestTheme.hashtags[0]

        script.startNode.labels.CurrentPixelDailies

    # Yesterday's Pixel Dailies
    messages.YesterdaysPixelDailies =
      weight: 1
      function: =>
        [themesCursor, submissionsCursor] = PADB.PixelDailies.Pages.Home.themes.query 2

        yesterdayTheme = themesCursor.fetch()[1]
        return unless yesterdayTheme?.hashtags?.length and yesterdayTheme.topSubmissions?.length

        topSubmission = yesterdayTheme.topSubmissions[0]

        _.extend script.ephemeralState(),
          pixelDailiesHashtag: yesterdayTheme.hashtags[0]
          pixelDailiesUser: topSubmission.user.name
          pixelDailiesFavorites: topSubmission.favoritesCount

        script.startNode.labels.YesterdaysPixelDailies

    # Transaction Message
    transactionMessages = RS.Components.TopSupporters.transactionMessages.find().fetch()
    @_playedTransactionMessageIds ?= []
    if transactionMessages.length
      messages.TransactionMessage =
        weight: Math.min transactionMessages.length, 3
        function: =>
          loop
            transactionMessage = Random.choice transactionMessages
            break unless transactionMessage._id in @_playedTransactionMessageIds

          @_playedTransactionMessageIds.push transactionMessage._id

          script.ephemeralState().transactionMessage = transactionMessage
          script.startNode.labels.TransactionMessage
          
    # Funny Sketches
    sketches = [
      'PlayHarder'
      'Talent'
      'RetrosLaboratory'
      'DaisyDaisy'
      'PodBayDoors'
      'RetroSwears'
      'OrangeSherbet'
      'ThemeHospital'
      'WoodChuck'
      'PapersPlease'
    ]
    @_playedSketches ?= []
    messages.FunnySketches =
      weight: Math.min sketches.length, 3
      function: =>
        loop
          sketch = Random.choice sketches
          break unless sketch in @_playedSketches

        @_playedSketches.push sketch
        script.startNode.labels[sketch]

    # Adjust weights by already played messages and construct possible choices.
    @_messageWeightsAdjustments ?= {}
    choices = []

    for id, message of messages
      choiceWeight = message.weight - (@_messageWeightsAdjustments[id] or 0)

      if choiceWeight
        choices.push
          id: id
          weight: choiceWeight
          function: message.function

    return unless choices.length

    totalWeight = _.sum _.map choices, 'weight'
    randomValue = Math.random() * totalWeight

    selectedChoice = null

    for choice in choices
      randomValue -= choice.weight
      if randomValue < 0
        selectedChoice = choice
        break

    # Execute this choice.
    scriptNode = selectedChoice.function()
    return unless scriptNode

    # Adjust weight for next time.
    @_messageWeightsAdjustments[selectedChoice.id] ?= 0
    @_messageWeightsAdjustments[selectedChoice.id]++

    # Rewire intro dialog node to point to our selection.
    introDialogNode = script.startNode.labels.Intro.next
    introDialogNode.next = scriptNode

    LOI.adventure.director.startBackgroundNode introDialogNode

  # Script

  initializeScript: ->
    @setThings @options.listener.avatars

  # Listener

  @avatars: ->
    burra: HQ.Actors.Burra
    retro: HQ.Actors.Retro
