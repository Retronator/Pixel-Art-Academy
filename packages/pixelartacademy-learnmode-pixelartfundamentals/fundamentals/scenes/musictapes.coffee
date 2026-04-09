LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.MusicTapes extends LOI.Adventure.Scene
  # displayedNotificationIds: a list of notification IDs that have already been displayed.
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.MusicTapes'

  @location: -> PAA.Music.Tapes

  @initialize()
  
  things: ->
    tapes = []
    
    # Tapes for Elements of art: line.
    if PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
      tapes.push
        artist: 'Extent of the Jam'
        title: 'musicdisk01'
      
      tapes.push
        artist: 'Shnabubula'
        title: 'Finding the Groove'

    # Tape for Elements of art: shape.
    if PAA.Tutorials.Drawing.ElementsOfArt.Shape.completed()
      tapes.push
        artist: 'HOME'
        title: 'Resting State'
      
    # Tape for Pixel art lines.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed()
      tapes.push
        artist: 'glaciære'
        'sides.0.title': 'shower'
        
    # Tape for Pixel art diagonals.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.completed()
      tapes.push
        artist: 'Revolution Void'
        title: 'The Politics of Desire'
    
    # Tape for Pixel art curves.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.completed()
      tapes.push
        artist: 'State Azure'
        title: 'Stellar Descent'
      
    # Tape for Pixel art line width.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.completed()
      tapes.push
        artist: 'Three Chain Links'
        'sides.0.title': 'The Happiest Days Of Our Lives'
    
    # Tape for Simplification.
    if LM.PixelArtFundamentals.Fundamentals.Goals.Simplification.Tutorial.completed()
      tapes.push
        artist: 'Holizna'
        title: 'Be Happy With Who You Are'
        
    # Tape for Shape language.
    if LM.Design.Fundamentals.Goals.ShapeLanguage.Learn.completed()
      tapes.push
        artist: 'Joseph Sacco'
        'sides.0.title': 'Lostalgia'
    
    tapes

  class @NotificationsProvider extends PAA.PixelPad.Systems.Notifications.Provider
    @id: -> "#{MusicTapes.id()}.NotificationsProvider"
    @initialize()
    
    @NotificationArtists =
      FirstTapes: 'Shnabubula'
      HOME: 'HOME'
      Glaciaere: 'glaciære'
      RevolutionVoid: 'Revolution Void'
      StateAzure: 'State Azure'
      ThreeChainLinks: 'Three Chain Links'
      Holizna: 'Holizna'
      JosephSacco: 'Joseph Sacco'
    
    availableNotificationIds: ->
      # See which tapes are available.
      tapeSelectors = LOI.adventure.currentTapeSelectors()
      potentialNotificationIds = []
      
      for className, artist of @constructor.NotificationArtists
        continue unless _.find tapeSelectors, (tape) => tape.artist is artist
        potentialNotificationIds.push MusicTapes[className].id()
        
      # Remove all notifications that were already displayed.
      displayedNotificationIds = LM.PixelArtFundamentals.Fundamentals.MusicTapes.state('displayedNotificationIds') or []
      _.difference potentialNotificationIds, displayedNotificationIds
      
  class @Notification extends PAA.PixelPad.Systems.Notifications.Notification
    @displayedId: ->
      # Override if the notification fulfills a different ID.
      @id()
    
    @displayStyle: -> @DisplayStyles.Always
    
    @retroClasses: ->
      body: PAA.PixelPad.Systems.Notifications.Retro.BodyClasses.Walkman
      
    displayedId: -> @constructor.displayedId()
      
    updateLastDisplayedTime: ->
      super arguments...
      
      displayedNotificationIds = LM.PixelArtFundamentals.Fundamentals.MusicTapes.state('displayedNotificationIds') or []
      displayedNotificationIds.push @displayedId()
      LM.PixelArtFundamentals.Fundamentals.MusicTapes.state 'displayedNotificationIds', displayedNotificationIds
  
  class @FirstTapes extends @Notification
    @id: -> "#{MusicTapes.id()}.FirstTapes"
    
    @message: -> """
      You can now play extra music!

      In the Music app, you'll find some good DOS chiptunes from Extent of the Jam as well as Shnabubula's piano improvisations that take me straight back to The Sims build mode.
    """
    
    @initialize()
  
  class @HOME extends @Notification
    @id: -> "#{MusicTapes.id()}.HOME"
    
    @message: -> """
      Hey, I got my hands on a demo tape by HOME a.k.a. the brilliant kid who started the chillsynth genre!
      
      You can find it in the Music app.
    """
    
    @initialize()
    
  class @Glaciaere extends @Notification
    @id: -> "#{MusicTapes.id()}.Glaciaere"
    
    @message: -> """
      I got you a new cassette tape with two vaporwave albums by Glaciære.
      
      You can find it in the Music app.
    """
    
    @initialize()
    
  class @RevolutionVoid extends @Notification
    @id: -> "#{MusicTapes.id()}.RevolutionVoid"
    
    @message: -> """
      It's time to get funky! You can now play Revolution Void in the Music app.
    """
    
    @initialize()
  
  class @StateAzure extends @Notification
    @id: -> "#{MusicTapes.id()}.StateAzure"
    
    @message: -> """
      If you want some relaxing, ambient music, I got a very long cassette tape from State Azure.
    """
    
    @initialize()
  
  class @ThreeChainLinks extends @Notification
    @id: -> "#{MusicTapes.id()}.ThreeChainLinks"
    
    @message: -> """
      I got even more music for you, two albums from Three Chain Links.
      He makes cool stuff inspired by the 80s and old video games.
    """
    
    @initialize()
  
  class @Holizna extends @Notification
    @id: -> "#{MusicTapes.id()}.Holizna"
    
    @message: -> """
      Time to draw and chill with some uplifting lo-fi beats from Holizna.
      
      You can play the new tape in the Music app.
    """
    
    @initialize()
  
  class @JosephSacco extends @Notification
    @id: -> "#{MusicTapes.id()}.JosephSacco"
    
    @message: -> """
      The Music app has a new cassette tape by Joseph Sacco,
      if you want some synthwave to transports you into a retro-futuristic world.
    """
    
    @initialize()
