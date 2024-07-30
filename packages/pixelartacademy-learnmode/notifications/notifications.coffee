PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Notifications
  # Conditional notifications
  
  class @MoreElementsOfArt extends PAA.PixelPad.Systems.Notifications.Notification
    @id: -> "PixelArtAcademy.LearnMode.Notifications.MoreElementsOfArt"
    
    @message: -> """
        I'm planning to add more elements of art during Early Access.

        Until then, focus just on the lines.
        This will build your foundation before tackling harder elements such as values and colors.
      """
    
    @displayStyle: -> @DisplayStyles.IfIdle
    
    @condition: ->
      # Show when some of the Elements of art: line tasks are completed.
      PAA.Tutorials.Drawing.ElementsOfArt.Line.completedAssetsCount() > 0
    
    @initialize()
    
    LM.ConditionalNotificationsProvider.registerNotificationClass @

  class @TheEnd extends LM.ConditionalNotificationsProvider.ConditionalNotification
    @id: -> "PixelArtAcademy.LearnMode.Notifications.TheEnd"
    
    @message: -> """
      You completed all the tasks there are in the demo, thank you for playing!
      
      I hope you liked the experience. If you did, wishlist the game to be notified when the game launches into Early Access on August 5.
    """
    
    @priority: -> 2
    
    @displayStyle: -> @DisplayStyles.Always
    
    @condition: ->
      # Show when no tasks are active.
      for chapter in LOI.adventure.currentChapters()
        for task in chapter.tasks
          return if task.active()
          
      true
      
    @initialize()
    
    LM.ConditionalNotificationsProvider.registerNotificationClass @
  
  # Quotes
  
  @quotes =
    DaVinciKnowing: "Da Vinci once said, \"Knowing is not enough; we must apply. Being willing is not enough; we must do.\""
    DaVinciBlackCanvas: "Da Vinci once said, \"A painter should begin every canvas with a wash of black, because all things in nature are dark except where exposed by the light.\""
    DaVinciNoDesire: "Da Vinci once said, \"Study without desire spoils the memory, and it retains nothing that it takes in.\""
    DaVinciNeverFinished: "Da Vinci once said, \"Art is never finished, only abandoned.\""
    DaVinciScienceArt: "Da Vinci once said, \"Study the science of art. Study the art of science. Develop your senses—especially learn how to see. Realize that everything connects to everything else.\""
    ConfuciusDontStop: "Confucius once said, \"It does not matter how slowly you go as long as you do not stop.\""
    PicassoEveryChild: "Picasso once said, \"Every child is an artist. The problem is how to remain an artist once you grow up.\""
    PicassoWhyNot: "Picasso once said, \"Others have seen what is and asked why. I have seen what could be and asked why not.\""
    PicassoLearnRules: "Picasso once said, \"Learn the rules like a pro, so you can break them like an artist.\""
    PicassoTomorrow: "Picasso once said, \"Only put off until tomorrow what you are willing to die having left undone.\""
    PicassoYoung: "Picasso once said, \"It takes a very long time to become young.\""
    PicassoDoing: "Picasso once said, \"I am always doing that which I can not do, in order that I may learn how to do it.\""
    PicassoMeaning: "Picasso once said, \"The meaning of life is to find your gift. The purpose of life is to give it away.\""
    AntoineDeSaintExuperyPerfeection: "Antoine de Saint-Exupéry once said, \"Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.\""
    JessicaHischeProcrastinate: "Jessica Hische once said, \"The work you do while you procrastinate is probably the work you should be doing for the rest of your life.\""
    DaliInspires: "Dali once said, \"A true artist is not one who is inspired, but one who inspires others.\""
    EinsteinImaginationEncirclesTheWorld: "Einstein once said, \"I am enough of an artist to draw freely upon my imagination. Imagination is more important than knowledge. Knowledge is limited. Imagination encircles the world.\""
    EinsteinImaginationWillGetYouEverywhere: "Einstein once said, \"Logic will get you from A to Z; imagination will get you everywhere.\""
    EinsteinKeepMoving: "Einstein once said, \"Life is like riding a bicycle. To keep your balance, you must keep moving.\""
    EinsteinMistake: "Einstein once said, \"Anyone who has never made a mistake has never tried anything new.\""
    EinsteinPassion: "Einstein once said, \"I have no special talents. I am only passionately curious.\""
    GandhiLearn: "Gandhi once said, \"Live as if you were to die tomorrow. Learn as if you were to live forever.\""
    VanGoghPaint: "Van Gogh once said, \"If you hear a voice within you say you cannot paint, then by all means paint and that voice will be silenced.\""
    TuringImpossible: "Turing once said, \"Those who can imagine anything, can create the impossible.\""
    BramStokerFailure: "Bram Stoker once said, \"We learn from failure, not from success!\""
    RichardFeynmannStudy: "Richard Feynmann once said, \"Study hard what interests you the most in the most undisciplined, irreverent and original manner possible.\""
    RoyTBennettExperience: "Roy T. Bennett once said, \"Some things cannot be taught; they must be experienced. You never learn the most valuable lessons in life until you go through your own journey.\""
    SylviaPlathDoubt: "Sylvia Plath once said, \"The worst enemy to creativity is self-doubt.\""
    MayaAngelouCreativity: "Maya Angelou once said, \"You can't use up creativity. The more you use, the more you have.\""
    KenRobinsonCuriosity: "Ken Robinson once said, \"Curiosity is the engine of achievement.\""
    HenriMatisseInspiration: "Henri Matisse once said, \"Don’t wait for inspiration. It comes while one is working.\""
    WaltDisneyDreams: "Walt Disney once said, \"All our dreams can come true, if we have the courage to pursue them.\""
    WaltDisneyDoing: "Walt Disney once said, \"The way to get started is to quit talking and begin doing.\""
    WaltDisneyUnique: "Walt Disney once said, \"The more you like yourself, the less you are like anyone else, which makes you unique.\""
    JohnDeweyReflecting: "John Dewey once said, \"We do not learn from experience... we learn from reflecting on experience.\""
    JohnDeweyArt: "John Dewey once said, \"Art is the most effective mode of communications that exists.\""
    EdCatmullPerfect: "Ed Catmull once said, \"Don’t wait for things to be perfect before you share them with others. Show early and show often. It’ll be pretty when we get there, but it won’t be pretty along the way.\""
    EdCatmullFailure: "Ed Catmull once said, \"If you aren’t experiencing failure, then you are making a far worse mistake: You are being driven by the desire to avoid it.\""
    EdCatmullUnexpected: "Ed Catmull once said, \"You’ll never stumble upon the unexpected if you stick only to the familiar.\""
    EdCatmullCreativity: "Ed Catmull once said, \"We humans like to know where we are headed, but creativity demands that we travel paths that lead to who-knows-where.\""
    AlanKayFuture: "Alan Kay once said, \"The best way to predict the future is to invent it.\""
    AlanWattsEngaged: "Alan Watts once said, \"This is the real secret of life—to be completely engaged with what you are doing in the here and now. And instead of calling it work, realize it is play.\""
    RoaldDahlPlay: "Roald Dahl once said, \"Life is more fun if you play games.\""
    GeorgeBernardShawPlaying: "George Bernard Shaw once said, \"We don't stop playing because we grow old; we grow old because we stop playing.\""
    BobRossMistakes: "Bob Ross once said, \"We don't make mistakes, just happy little accidents.\""
    BobRossTalent: "Bob Ross once said, \"Talent is a pursued interest. Anything that you're willing to practice, you can do.\""
    BobRossBelieving: "Bob Ross once said, \"The secret to doing anything is believing that you can do it. Anything that you believe you can do strong enough, you can do. Anything. As long as you believe.\""
    ThichNhatHanhReflecting: "Thich Nhat Hanh once said, \"If learning is not followed by reflecting and practicing, it is not true learning.\""
  
  for quoteId, quote of @quotes
    do (quoteId, quote) =>
      class @[quoteId] extends PAA.PixelPad.Systems.Notifications.Notification
        @id: -> "PixelArtAcademy.LearnMode.QuoteNotifications.#{quoteId}"
        
        @message: -> quote
        
        @priority: -> -1
        
        @retroClassesDisplayed: ->
          face: PAA.PixelPad.Systems.Notifications.Retro.FaceClasses.Peaceful
        
        @initialize()
        
        LM.RandomNotificationsProvider.registerNotificationClass @
