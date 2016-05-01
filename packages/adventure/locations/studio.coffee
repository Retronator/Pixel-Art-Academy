LOI = LandsOfIllusions
PAA = PixelArtAcademy

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class PAA.Adventure.Locations.Studio extends LOI.Adventure.Location
  keyName: -> 'studio'
  displayName: -> "studio room"

  constructor: ->
    super

    jessie = new Actor
    jessie.displayName = 'Jessie'
    jessie.sprite = '/assets/adventure/character.png'

    jessie.addAbility Talking
    jessie.addAbility Action,
      verb: "Turn-in new game artwork"
      action: =>
        @director.startScript sceneDay2TurnIn

    corinne = new Actor
    corinne.displayName = 'Corinne'
    corinne.sprite = '/assets/adventure/placeholder-char.png'

    corinne.addAbility Talking
    corinne.addAbility Action,
      verb: "Inquire about job"
      action: =>
        @director.startScript sceneDay2Info

    @addActor jessie
    @addActor corinne

    artstudio = new Actor
    artstudio.displayName = 'ArtStudio'
    artstudio.sprite = '/assets/adventure/artstudio.png'
    @addActor artstudio

    scene1 = LOI.Adventure.Script.create
      director: @director

      actors:
        jessie: jessie

      script:
        """
          jessie: You're the artist we brought in, right?
          jessie: Cool, cool. Good to see you. Thanks for
          jessie: coming. We're currently developing
          jessie: a snake game and we've programmed all the
          jessie: game functionality already. My co-worker
          jessie: has for more information.
        """

    scene2 = LOI.Adventure.Script.create
      director: @director

      actors:
        corinne: corinne

      script:
        """
          corinne: Hey! Good to meet you. Right now, we really
          corinne: really need a sprite of a SNAKE and some FOOD
          corinne: for it to eat.
          corinne: The desk over there should have everything
          corinne: you need to draw. At any point, you can
          corinne: load the PICO-8 app on your PIXELBOY to preview
          corinne: what your sprites look like in game.
          corinne: Give your work to my co-worker when you're done.
        """

    sceneTurnIn = LOI.Adventure.Script.create
      director: @director

      actors:
        jessie: jessie

      script:
        """
          jessie: Did you finish? Great! We'll put this into
          jessie: the game as soon as we can. Thanks!
          jessie: If you want to come back tomorrow, we'll
          jessie: have another assignment for you.
        """

    sceneDay2Intro = LOI.Adventure.Script.create
      director: @director

      actors:
        jessie: jessie

      script:
        """
          jessie: Welcome back! We put your sprites into the
          jessie: game and they look fantastic! Good job!
          jessie: Our snake game features different types of
          jessie: food for the snake that the player can get.
          jessie: Today we need two more sprites from you.
          jessie: They should depict two different types of
          jessie: FOOD for the snake to eat. It doesn't matter
          jessie: what two. My co-worker has more information.
        """

    sceneDay2Info = LOI.Adventure.Script.create
      director: @director

      actors:
        corinne: corinne

      script:
        """
          corinne: We were thinking of foods that snakes eat.
          corinne: They'll eat anything small and alive apparently.
          corinne: But this is a video game, so our snake can
          corinne: eat apples and other non-animal things.
        """

    sceneDay2TurnIn = LOI.Adventure.Script.create
      director: @director

      actors:
        jessie: jessie

      script:
        """
          jessie: Done? Awesome! We'll put this
          jessie: into the game tonight.
          jessie: We still need some artwork,
          jessie: so come back tomorrow
          jessie: for another assignment.
        """
