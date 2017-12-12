AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
Blog = Retronator.Blog

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Daily extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Daily'
  @url: -> 'daily/*'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Retronator Daily"

  @description: ->
    "
      It's the newspaper from Retronator, full of daily pixel art news.
    "

  @initialize()

  constructor: ->
    super
    
    @page = new ComputedField =>
      page = parseInt FlowRouter.getParam 'parameter2'

      page = 1 if _.isNaN page

      page

  onCreated: ->
    super

    @postsPerPage = 15

    @autorun (computation) =>
      @_postsSubscription = Blog.Post.all.subscribe (@page() + 1) * @postsPerPage

    @edition = new ComputedField =>
      return null unless @_postsSubscription.ready()

      posts = Blog.Post.documents.find({},
        sort:
          time: -1
        limit: @postsPerPage
        skip: (@page() - 1) * @postsPerPage
      ).fetch()

      new @constructor.Edition posts, true

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  url: ->
    page = @page()
    return 'daily' if page is 1

    "daily/#{page}"

  backButtonCallback: ->
    =>
      handled = @edition().theme.onBackButtonClick()

      if handled
        cancel: true

      else
        # Theme did not handle the back button, so we need to close the Daily.
        LOI.adventure.deactivateCurrentItem()

  # Listener

  onCommand: (commandResponse) ->
    daily = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Read, Vocabulary.Keys.Verbs.Use], daily.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem daily

  class @Edition extends AM.Component
    @register 'Retronator.HQ.Items.Daily.Edition'

    constructor: (@posts, @homePage) ->
      super

    onCreated: ->
      super

      @daily = @ancestorComponentOfType HQ.Items.Daily

    onRendered: ->
      super

      @theme = new HQ.Items.Daily.Theme
      @display = @callAncestorWith 'display'

      # Force repositioning of overlay elements, since we've inserted dynamic safe areas.
      @overlay = @ancestorComponentOfType LOI.Components.Overlay
      @overlay.onResize()

      @autorun (computation) =>
        # Depend on scale changes.
        @display.scale()

        # Resize the theme.
        @theme?.onResize()

    firstPost: ->
      _.first @posts

    previousPageUrl: ->
      page = @daily.page()
      return if page < 2

      "/daily/#{page - 1}"

    nextPageUrl: ->
      return if @posts.length < @daily.postsPerPage

      page = @daily.page()
      "/daily/#{page + 1}"

    date: ->
      post = @currentData()

      post.time.toLocaleString Artificial.Babel.currentLanguage(),
        month: 'long'
        day: 'numeric'
        year: 'numeric'
        weekday: 'long'

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

LOI.Adventure.registerDirectRoute "daily/*", =>
  # Show the daily if we need to.
  LOI.adventure.goToItem HQ.Items.Daily unless LOI.adventure.activeItemId() is HQ.Items.Daily.id()
