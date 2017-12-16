class Retronator.HQ.Items.Daily.Theme
  constructor: ->
    # Is the theme running on Tumblr?
    @tumblr = false

    # Get about page dynamic info.
    if @tumblr
      $.getJSON 'https://hq.retronator.com/daily/data.json', (data) =>
        @processBlogInfo data.blogInfo
        @processSupporterMessages data.supporterMessages
        @processSupportersWithNames data.supportersWithNames

    else
      Retronator.Blog.getData (error, data) =>
        if error
          console.error error
          return

        @processBlogInfo data.blogInfo
        @processSupporterMessages data.supporterMessages
        @processSupportersWithNames data.supportersWithNames

    # Process each post.
    $('.post').each (postIndex, post) =>
      $post = $(post)
      
      # Wrap consecutive paragraphs into three-column format.
      paragraphs = []

      children = $post.children()

      for child, index in children
        if child.tagName.toLowerCase() is 'p'
          paragraphs.push child

          # See if we've reached the last paragraph.
          nextChild = children[index + 1]
          if not nextChild or nextChild.tagName.toLowerCase() isnt 'p'
            # Wrap the paragraphs into a single block.
            $(paragraphs).wrapAll('<div class="paragraphs-block"/>')
            $paragraphBlock = $(paragraphs[0]).parent()

            # Clean up the paragraphs.
            paragraphs = []

            # Prevent really short columns.
            $paragraphBlock.css columnCount: 1 if $paragraphBlock.width() / $paragraphBlock.height() > 5

      # Process sources. Remove reblog root name if there is a title.
      $reblogLink = $post.find('.reblog.source .link')
      $reblogLink.find('.name').remove() if $reblogLink.find('.title').text()
      
      # If direct source is present, state reblog as via.
      $directSource = $post.find('.direct.source')
      if $directSource.length and $reblogLink.length
        $directSource.append(" (via ").append($reblogLink).append(")")
        $post.find('.reblog.source').remove()

    # Wire up changes that happen on resizes.
    if @tumblr
      $(window).resize => @onResize()

      # Trigger it for the first size to initialize.
      @onResize()

    # Wire up back button, or remove it if using the one from adventure interface.
    if @tumblr
      $('.back-button').click (event) => @onBackButtonClick()

    else
      $('.back-button').remove()

    @$newspaper = $('.newspaper')

    if $('.frontpage').length
      # We're on an index page. Copy latest date to frontpage and about page.
      $('.frontpage .date').text $('.post:first .date .value').text()
      $('.about .date').text $('.post:first .date').text()

      # Build the headlines.
      @initializeHeadlineDesigns()
      @layoutFrontpageHeadlines()

      # Wire the about link.
      $('.folio .about').click (event) =>
        @goToInsideContent $('.about.page')

      # Write back issue texts.
      processBackIssues = ($backIssues) ->
        $backIssues.each (index, backIssue) =>
          $backIssue = $(backIssue)
          page = parseInt $backIssue.data('page')

          # Apply one of the four back-issue covers.
          coverImage = (page - 1) % 4 + 1
          $backIssue.addClass("cover-#{coverImage}")

          # Nudge unless it's the last issue.
          unless index is $backIssues.length - 1
            $backIssue.css
              left: "#{Math.floor Math.random() * 7 - 3}rem"

          $text = $backIssue.find('.text')

          unless $text.length
            $backIssue.addClass('current')
            return

          text = page - 1

          switch text
            when 0 then text = "Latest issue"
            when 1 then text = "1 issue ago"
            else text = "#{text} issues ago"

          $text.text(text)

      processBackIssues $('.frontpage-area .back-issue')
      processBackIssues $('.inside-content-area .back-issue')

      # Normalize case of tag pages.
      targetTag = _.kebabCase $('.tag-ear').eq(0).text()

      if targetTag
        @isTagPage = true

        tagsFrequency = {}
        $('.tags .tag').each (index, tag) =>
          tag = $(tag).text()
          tagsFrequency[tag] ?= 0
          tagsFrequency[tag]++

        tags = ({tag, count} for tag, count of tagsFrequency)

        # Filter down to only tags that vary only in case.
        tags = _.filter tags, (tag) => targetTag is _.kebabCase tag.tag

        # Find the most frequent variant of the tag.
        tags = _.sortBy tags, 'count'
        bestTag = _.last tags

        $('.tag-ear .text').text(bestTag.tag)

    else
      # We're on a permalink page.
      @isPermalinkPage = true
      @$newspaper.addClass('permalink')

      # Start on the inside.
      @$newspaper.addClass('inside').addClass('scroll-inside')

  onBackButtonClick: ->
    if @$newspaper.hasClass('inside') and not @isPermalinkPage
      # Scroll the frontpage to a point that matches where inside the content we reached.
      $frontpageScrollContent = $('.frontpage-area .scroll-content')

      # Figure out which page we're on (the one in the upper half of the screen).
      halfHeight = $(window).height() / 2

      if $('.about.page').position().top < halfHeight
        # We reached the about page, so just scroll back to the top of the frontpage.
        $frontpageScrollContent.scrollTop 0

      else
        # We're not that far so we must be on one of the posts. Figure out which.
        currentPostIndex = 0

        for post, postIndex in $('.post')
          currentPostIndex = postIndex if $(post).position().top < halfHeight

        # Position frontpage so that the current post headline is in the middle.
        $headline = $(".frontpage .headline[data-index='#{currentPostIndex}']")

        headlineTop = $headline.offset().top + $frontpageScrollContent.scrollTop()

        $frontpageScrollContent.scrollTop headlineTop - halfHeight

      # Start transition.
      @$newspaper.removeClass('inside')

      setTimeout =>
        @$newspaper.removeClass('scroll-inside')
      ,
        1000
      
      return true

    # Check if we should get redirected to the main blog link.
    if @isPermalinkPage or @isTagPage or not @$newspaper.hasClass('homepage')
      if @tumblr
        location.href = Retronator.HQ.Items.Daily.BlogUrl

      else
        FlowRouter.go '/daily'

      return true

    # We're already at the main link, so return back to HQ.
    false

  onResize: ->
    @resizeIframes()

  # Resizes iFrames to full-width.
  resizeIframes: ->
    targetWidth = $('.post').width()

    $('.post iframe').each (postIndex, element) =>
      $iframe = $(element)
      width = $iframe.attr('width')
      height = $iframe.attr('height')

      # Percentage-based iframes should retain their height.
      return if width.match /%/

      targetHeight = targetWidth / width * height

      $iframe.attr
        width: targetWidth
        height: targetHeight

  processBlogInfo: (blogInfo) ->
    $('.circulation .value').text(blogInfo.followers.toLocaleString Artificial.Babel.currentLanguage())

  processSupporterMessages: (messages) ->
    messages = _.sortBy messages, (message) -> -message.priority
    $messages = $('.supporters .messages')

    for message in messages
      $message = $("<li class='message'></li>")
      $message.append("<blockquote class='text'>#{message.message}</blockquote>")
      $message.append("<div class='name'>#{message.name}</div>") if message.name
      $messages.append($message)

  processSupportersWithNames: (users) ->
    $supportersTable = $('.supporters .supporters-table')
    for user in users
      $supporter = $("<tr>")
      $supporter.append("<td class='name'>#{user.name}</td>")
      $supporter.append("<td class='amount'>#{user.amount}</td>")
      $supportersTable.append($supporter)
