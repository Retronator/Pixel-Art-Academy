AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
C2 = PixelArtAcademy.Season1.Episode0.Chapter2

Vocabulary = LOI.Parser.Vocabulary

class C2.Items.VideoTablet extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Items.VideoTablet'
  @url: -> 'video-tablet'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "video tablet"
  @shortName: -> "tablet"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's a tablet with a selection of videos.
    "

  @initialize()

  isVisible: -> false
    
  onCreated: ->
    super
    
    # Analyze player's answers in the Chapter 2/Immersion/Room script.
    scriptsState = LOI.adventure.gameState().scripts
    roomState = _.nestedProperty scriptsState, C2.Immersion.Room.id()

    weights =
      gaming: roomState.videoGaming
      nonGaming: roomState.videoNonGaming
      pixelArt: roomState.videoPixelArt
      gameDev: roomState.videoGameDev
      art: roomState.videoArt
      tech: roomState.videoTech
      relax: roomState.videoRelax
      think: roomState.videoThink

    # Multiply user weights with videos' weights to create a score.
    videos = for video in @constructor.Videos
      score = 0
      
      for tag, weight of video.weights
        score += weights[tag] * weight
      
      video: video
      score: score
      random: Math.random()

    # Sort by score, and randomly within the same score.
    videos = _.reverse _.sortBy videos, ['score', 'random']

    # Display the first four.
    @videos = videos[..3]
    
    @selection = new ReactiveField null
    
  events: ->
    super.concat
      'click .videos .video': @onClickVideo
      'click .close-button': @onClickCloseButton
      
  onClickVideo: (event) ->
    video = @currentData()

    @selection video

  onClickCloseButton: (event) ->
    @selection null

  backButtonCallback: ->
    =>
      if @selection()
        @selection null
        return cancel: true

      LOI.adventure.deactivateActiveItem()

  class @Video extends AM.Component
    @register 'PixelArtAcademy.Season1.Episode0.Chapter2.Items.VideoTablet.Video'

    onRendered: ->
      super

      # Load the thumbnail
      video = @currentData()

      image = new Image
      image.addEventListener 'load', =>
        canvas = @$('.thumbnail')[0]
        context = canvas.getContext '2d'

        scale = canvas.width / image.width
        height = image.height * scale

        context.imageSmoothingEnabled = false
        context.drawImage image, 0, (canvas.height - height) / 2, canvas.width, height
      ,
        false

      # Initiate the loading.
      image.src = "https://img.youtube.com/vi/#{video.id}/0.jpg"

      Meteor.setTimeout =>
        # Move author on second row, if it's not.
        author = @$('.author')
        title = @$('.title')

        if author.offset().top is title.offset().top
          title.after '<br/>'
      ,
        0
