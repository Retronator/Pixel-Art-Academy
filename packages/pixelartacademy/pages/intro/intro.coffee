AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pages.Intro extends AM.Component
  @register 'PixelArtAcademy.Pages.Intro'

  onCreated: ->
    super

    # Create pixel scaling display.
    @display = new Artificial.Mirage.Display
      safeAreaWidth: 240
      safeAreaHeight: 180
      minScale: 2

    @characterId = new ReactiveField null
    @introStarted = new ReactiveField false
    @introFinished = new ReactiveField false

    # Listen for end of intro and available character.
    @autorun =>
      @subscribe 'LandsOfIllusions.Accounts.Character.charactersForUser', Meteor.userId()

      characterId = @characterId()
      return unless characterId

      character = LOI.Accounts.Character.documents.findOne characterId
      return unless character and @introFinished()

      LOI.Accounts.switchCharacter characterId

  onRendered: ->
    super

    $('html').addClass('pixel-art-academy-style-intro')

  onDestroyed: ->
    super

    $('html').removeClass('pixel-art-academy-style-intro')

  startNewGame: ->
    # Create a user with random username/password.
    Accounts.createUser
      username: Random.id()
      password: Random.id()
    ,
      (error) =>
        if error
          console.error "User creation failed", error
          return

        # User was created successfully. Create a new character.
        @characterId Random.id()

        Meteor.call 'PixelArtAcademy.Pages.Intro.characterInitialize', Meteor.userId(), @characterId()

        # Start the intro transition.
        @introStarted true

        # On transition finish, load the character.
        Meteor.setTimeout =>
          @$('.fade-overlay').velocity
            opacity: 1
          ,
            duration: 2000
            complete: =>
              @introFinished true
        ,
          10000

  startedClass: ->
    'started' if @introStarted()

  events: ->
    super.concat
      'click': @onClick

  onClick: (event) ->
    @startNewGame()

