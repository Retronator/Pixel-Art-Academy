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

  onCreated: ->
    super

    @postsPerPage = 15

    # Create URL state. Our options are:
    # - index page        /page/x
    # - index & tag page  /tagged/y/page/x
    # - permalink page    /post/id/slug
    @_urlState = null
    @urlState = new ComputedField =>
      # Preserve state when url doesn't address the daily (for example, if opening up the menu).
      return @_urlState unless FlowRouter.getParam('parameter1') is 'daily'

      switch FlowRouter.getParam 'parameter2'
        when 'post'
          @_urlState =
            postId: parseInt FlowRouter.getParam 'parameter3'
          
        when 'tagged'
          @_urlState =
            tag: _.kebabCase FlowRouter.getParam 'parameter3'
            page: FlowRouter.getParam 'parameter5'
        
        else
          @_urlState =
            page: FlowRouter.getParam 'parameter3'

      # Make sure page is a valid integer.
      @_urlState.page = parseInt @_urlState.page
      @_urlState.page = 1 if _.isNaN(@_urlState.page) or @_urlState.page < 1

      @_urlState
    ,
      EJSON.equals

    # Create issue instance based on the URL state.
    @issue = new ReactiveField null
    @autorun (computation) =>
      return unless urlState = @urlState()

      Blog.Post.getIssueData urlState, (error, issueData) =>
        return console.error error if error
        
        _.extend issueData, {urlState}

        @issue new @constructor.Issue issueData

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  url: ->
    # Return the wildcard URL so we don't rewrite it before we manage to parse parameters into our URL state.
    return super unless @isCreated()

    url = 'daily'

    return url unless urlState = @urlState()

    if urlState.postId
      url = "#{url}/post/#{urlState.postId}"

      # Try to load the slug as well.
      if slug = @issue()?.posts()[0].tumblr.slug
        url = "#{url}/#{slug}"

      else
        # Preserve the current slug until a new one arrives.
        url = "#{url}/*"

    else if urlState.tag
      url = "#{url}/tagged/#{urlState.tag}"

    if urlState.page > 1
      url = "#{url}/page/#{urlState.page}"

    url

  backButtonCallback: ->
    =>
      handled = @issue().theme.onBackButtonClick()

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

  class @Issue extends AM.Component
    @register 'Retronator.HQ.Items.Daily.Issue'

    constructor: (@data) ->
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

    posts: ->
      @data.posts

    permalinkPage: ->
      @data.urlState.postId

    tagPage: ->
      @data.urlState.tag

    tag: ->
      @data.urlState.tag

    urlSafeTag: ->
      _.kebabCase @data.urlState.tag

    indexPage: ->
      not @permalinkPage()

    homePage: ->
      @indexPage() and @data.urlState.page is 1

    firstPost: ->
      _.first @data.posts

    currentPage: ->
      @data.urlState.page

    blogUrl: -> '/daily'

    previousPageUrl: ->
      page = @data.urlState.page
      return if page < 2

      @_pageUrl page - 1

    nextPageUrl: ->
      return if @data.urlState.page < @data.pagesCount

      @_pageUrl @data.urlState.page + 1

    jumpPagination: (count) ->
      page = @data.urlState.page
      min = Math.ceil page - count / 2
      max = min + count - 1

      min = Math.max min, 1
      max = Math.min max, @data.pagesCount

      [min..max]

    jumpCurrentPage: ->
      page = @currentData()
      page is @data.urlState.page

    jumpPage: ->
      not @jumpCurrentPage()

    jumpPageUrl: ->
      page = @currentData()
      @_pageUrl page

    _pageUrl: (page) ->
      url = '/daily'
      url = "#{url}/tagged/#{@data.urlState.tag}" if @data.urlState.tag
      return url if page is 1

      "#{url}/page/#{page}"

    date: ->
      post = @currentData()

      post.time.toLocaleString Artificial.Babel.currentLanguage(),
        month: 'long'
        day: 'numeric'
        year: 'numeric'
        weekday: 'long'

    permalink: ->
      post = @currentData()

      "/daily/post/#{post.tumblr.id}/#{post.tumblr.slug}"

    tagUrl: ->
      tag = @currentData()
      "/daily/tagged/#{_.kebabCase tag}"

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
      
      if post.video.url
        "<video src='#{post.video.url}' controls preload='none' poster='#{post.video.thumbnail.url}'></video>"
        
      else
        players = _.sortBy post.video.player, (player) => player.width
        _.last(players).embed_code

LOI.Adventure.registerDirectRoute "daily/*", =>
  # Show the daily if we need to.
  LOI.adventure.goToItem HQ.Items.Daily unless LOI.adventure.activeItemId() is HQ.Items.Daily.id()
