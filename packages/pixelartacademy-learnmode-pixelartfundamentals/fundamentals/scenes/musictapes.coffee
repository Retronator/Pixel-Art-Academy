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
    
    # You immediately get the first tapes.
    # TODO: When more original compositions are added, move these as rewards later on.
    tapes.push
      artist: 'Extent of the Jam'
      title: 'musicdisk01'
    
    tapes.push
      artist: 'Shnabubula'
      title: 'Finding the Groove'

    # Tape for Elements of art: line.
    if PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
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
    
    availableNotificationIds: ->
      # See which tapes are available.
      return [] unless musicTapes = LOI.adventure.getCurrentScene MusicTapes
      tapes = musicTapes.things()
      
      potentialNotificationIds = []
      
      for className, artist of @constructor.NotificationArtists
        continue unless _.find tapes, (tape) => tape.artist is artist
        potentialNotificationIds.push MusicTapes[className].id()
        
      # Remove all notifications that were already displayed.
      displayedNotificationIds = LM.PixelArtFundamentals.Fundamentals.MusicTapes.state('displayedNotificationIds') or []
      _.difference potentialNotificationIds, displayedNotificationIds
      
  class @Notification extends PAA.PixelPad.Systems.Notifications.Notification
    @displayStyle: -> @DisplayStyles.IfIdle
    
    updateLastDisplayedTime: ->
      super arguments...
      
      displayedNotificationIds = LM.PixelArtFundamentals.Fundamentals.MusicTapes.state('displayedNotificationIds') or []
      displayedNotificationIds.push @id()
      LM.PixelArtFundamentals.Fundamentals.MusicTapes.state 'displayedNotificationIds', displayedNotificationIds
  
  class @FirstTapes extends @Notification
    @id: -> "#{MusicTapes.id()}.FirstTapes"
    
    @message: -> """
      You can now play extra music!

      In the Music app, you'll find some good DOS chiptunes from Extent of the Jam as well as Shnabubula's piano improvisations that take me straight back to The Sims build mode.
    """

    @displayStyle: -> @DisplayStyles.Always
    
    @initialize()
  
  class @HOME extends @Notification
    @id: -> "#{MusicTapes.id()}.HOME"
    
    @message: -> """
      Hey, I got my hands on a demo album by HOME a.k.a. the brilliant kid who started the chillsynth genre!
      
      You can find it in the Music app.
    """
    
    @initialize()
    
  class @Glaciaere extends @Notification
    @id: -> "#{MusicTapes.id()}.Glaciaere"
    
    @message: -> """
      I got you a new cassette tape with two vaporwave albums by Glaciære.
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
      I got even more music for you, two albums from Three Chain Links
      who makes cool stuff inspired by the 80s and old video games.
    """
    
    @initialize()
