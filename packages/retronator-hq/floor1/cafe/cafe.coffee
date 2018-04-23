LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Cafe extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Cafe'
  @url: -> 'retronator/cafe'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator Café"
  @shortName: -> "café"
  @description: ->
    "
      The cosy café has a handful of tables with artsy folks occupying most of them.
      The north wall displays a selection of artworks from the current featured pixel artist. In the south
      there is a self-serve bar and Burra's carefully decorated workstation. A passageway connects to the coworking space
      in the west, and there are big stairs heading up to the store.
    "

  @listeners: ->
    super.concat [
      @BurraListener
    ]
  
  @initialize()

  constructor: ->
    super

    @loginButtonsSession = Accounts._loginButtonsSession

  things: -> [
    HQ.Items.Daily
    HQ.Cafe.Artworks
    HQ.Cafe.Burra
    SanFrancisco.Soma.Items.Map unless SanFrancisco.Soma.Items.Map.state 'inInventory'
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Up}": HQ.Store
    "#{Vocabulary.Keys.Directions.Northwest}": HQ.Store
    "#{Vocabulary.Keys.Directions.West}": HQ.Coworking
    "#{Vocabulary.Keys.Directions.East}": SanFrancisco.Soma.SecondStreet
    "#{Vocabulary.Keys.Directions.Out}": SanFrancisco.Soma.SecondStreet

  class @BurraListener extends LOI.Adventure.Listener
    @id: -> "Retronator.HQ.Cafe.Burra"

    @scriptUrls: -> [
      'retronator_retronator-hq/floor1/cafe/burra.script'
      'retronator_retronator-hq/floor1/cafe/burra-character.script'
    ]

    class @UserScript extends LOI.Adventure.Script
      @id: -> "Retronator.HQ.Cafe.Burra"
      @initialize()

      initialize: ->
        @setCurrentThings burra: HQ.Actors.Burra

        @setCallbacks
          OpenRetronatorMagazine: (complete) => @openWebsite 'https://medium.com/retronator-magazine', complete
          OpenPixelDailiesArchive: (complete) => @openWebsite 'https://retronator.com/pixeldailies', complete
          OpenPracticalPixels: (complete) => @openWebsite 'https://medium.com/practical-pixels', complete
          OpenYouTube: (complete) => @openWebsite 'https://www.youtube.com/retronator48k', complete

          Register: (complete) =>
            # Hook back into the Chapter 2 registration script.
            cafeScene = LOI.adventure.getCurrentThing PAA.Season1.Episode0.Chapter2.Registration.Cafe
            cafeListener = cafeScene.listeners[0]

            cafeListener.startScript label: 'PlayPixelArtAcademy'

            complete()
            
          ReceiveMap: (complete) =>
            SanFrancisco.Soma.Items.Map.state 'inInventory', true
            
            complete()

          C3Map: (complete) =>
            # To trigger the animation after multiple asks, first turn it off.
            SanFrancisco.Soma.Items.Map.state 'c3Highlighted', false

            # Highlight after half a second so that it animates after the map opens.
            Meteor.setTimeout =>
              SanFrancisco.Soma.Items.Map.state 'c3Highlighted', true
            ,
              500

            LOI.adventure.scriptHelpers.itemInteraction
              item: LOI.adventure.getCurrentThing SanFrancisco.Soma.Items.Map
              callback: => complete()

      openWebsite: (url, complete) =>
        website = window.open url, '_blank'
        website.focus()

        # Wait for our window to get focus.
        $(window).on 'focus.openWebsite', =>
          complete()
          $(window).off '.openWebsite'

    class @CharacterScript extends LOI.Adventure.Script
      @id: -> "Retronator.HQ.Cafe.BurraCharacter"
      @initialize()

      initialize: ->
        @setCurrentThings burra: HQ.Actors.Burra

    @initialize()

    onScriptsLoaded: ->
      @userScript = @scripts[@constructor.UserScript.id()]
      @characterScript = @scripts[@constructor.CharacterScript.id()]

    onCommand: (commandResponse) ->
      return unless burra = LOI.adventure.getCurrentThing HQ.Actors.Burra

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, burra.avatar]
        action: =>
          LOI.adventure.director.startScript if LOI.character() then @characterScript else @userScript
