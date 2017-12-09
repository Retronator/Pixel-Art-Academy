LOI = LandsOfIllusions
HQ = Retronator.HQ
Blog = Retronator.Blog

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Daily extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Daily'
  @url: -> 'daily'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Retronator Daily"

  @description: ->
    "
      It's the newspaper from Retronator, full of daily pixel art news.
    "

  @initialize()

  onCreated: ->
    super

    @postsCount = 15

    @_postsSubscription = Blog.Post.all.subscribe @postsCount

    @homePage = new ReactiveField true

  onRendered: ->
    super

    # Initialize the theme after all the posts have been inserted.
    @autorun (computation) =>
      return unless @_postsSubscription.ready()
      computation.stop()

      @theme = new @constructor.Theme

    @display = @callAncestorWith 'display'

    @autorun (computation) =>
      # Depend on scale changes.
      @display.scale()

      # Resize the theme.
      @theme?.onResize()

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  firstPost: ->
    _.first @posts().fetch()

  date: ->
    post = @currentData()

    post.time.toLocaleString Artificial.Babel.currentLanguage(),
      month: 'long'
      day: 'numeric'
      year: 'numeric'
      weekday: 'long'

  posts: ->
    Blog.Post.documents.find {},
      sort:
        time: -1
      limit: 15

  isPostText: ->
    post = @currentData()
    post.type is Blog.Post.Types.Text

  isPostPhoto: ->
    post = @currentData()
    post.type is Blog.Post.Types.Photo and post.photos.length is 1 and not @isPostPanorama()

  isPostPanorama: ->
    post = @currentData()
    return unless post.type is Blog.Post.Types.Photo and post.photos.length is 1

    photo = post.photos[0].original_size
    ratio = photo.width / photo.height

    # Panorama posts are at least 3:1 and wider than 1000.
    # https://staff.tumblr.com/post/40779375054/panoramas
    ratio > 3 and photo.width > 1000

  isPostPhotoset: ->
    post = @currentData()
    post.type is Blog.Post.Types.Photo and post.photos.length > 1

  isPostVideo: ->
    post = @currentData()
    post.type is Blog.Post.Types.Video

  isPostQuote: ->
    post = @currentData()
    post.type is Blog.Post.Types.Quote

  isPostAnswer: ->
    post = @currentData()
    post.type is Blog.Post.Types.Answer

  isPostChat: ->
    post = @currentData()
    post.type is Blog.Post.Types.Chat

  isPostAudio: ->
    post = @currentData()
    post.type is Blog.Post.Types.Audio

  isPostLink: ->
    post = @currentData()
    post.type is Blog.Post.Types.Link

  videoPlayer: ->
    post = @currentData()
    players = _.sortBy post.video.player, (player) => player.width
    _.last players

  # Listener

  onCommand: (commandResponse) ->
    daily = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Read, Vocabulary.Keys.Verbs.Use], daily.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem daily
