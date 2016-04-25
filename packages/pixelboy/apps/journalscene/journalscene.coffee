AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.JournalScene extends PAA.PixelBoy.OS.App
  @register 'PixelArtAcademy.PixelBoy.Apps.JournalScene'

  displayName: ->
    "Journal"

  keyName: ->
    'journalscene'

  onCreated: ->
    super

    @pageLeftHeading = new ReactiveField null
    @pageLeftText = new ReactiveField null
    @pageRightHeading = new ReactiveField null
    @pageRightText = new ReactiveField null
    @pageCommand = new ReactiveField null

    # watch for new text and blast.js it in as it comes
    @autorun =>
      #hide first so that as it comes in, it doesn't flash
      $('.page-left, .page-right').css 'opacity', 0
      # start with blast.js to split up our lines
      setTimeout ->
        $('.journal-text:not(.blast)').blast delimiter: 'word'
        #animate blast in
        $('.page-left, .page-right').css('opacity', 1)
        $('.blast').velocity 'transition.fadeIn', {stagger: 75, duration: 50}
      , 100 #setTimeout bc something's running before something else


    part1 = "Today is going to be a good day! A game development company contacted me and asked me to contribute artwork to their current project. I'm heading to their studio today to work. They haven't told me what the project is - I'm sure it's a great one though."
    command1 = "Go to game studio"

    part2 = "I drew these sprites for the game: [IMG] [IMG] It was really cool to see my graphics in an actual game. They've asked me to come back tomorrow to do more work." #Click to go to day 2
    command2 = "Sleep until tomorrow"

    part3 = "Today they asked me to draw food for the snake in their game. It was really hard to decide on two food items, but I managed: [IMG] [IMG]. I'm going back tomorrow to keep working on their game with them. I can't wait!"
    command3 = "Sleep until tomorrow"

    @pageLeftHeading "Day 1:"
    @pageLeftText part2
    @pageCommand command2

  onRendered: ->
    super

    setTimeout ->
      $('.journal-command').velocity 'transition.slideUpIn'
    , 4500
