class Retronator.HQ.Items.Daily.Theme
  constructor: ->
    # Is the theme running on Tumblr?
    @tumblr = false

    # Get about page dynamic info.
    if @tumblr
      $.getJSON 'https://hq.retronator.com/daily/data.json', (data) =>
        @processBlogData data

    else
      Retronator.Blog.getData (error, data) =>
        if error
          console.error error
          return

        @processBlogData data

    # Process each post.
    $('.post').each (postIndex, post) =>
      $post = $(post)

      # Create photosets.
      $photoset = $post.find('.photoset')
      if $photoset.length
        # Get layout and make sure it's a string so we can iterate over it.
        layout = "#{$photoset.data('layout')}"
        images = $photoset.find('img').toArray()

        for layoutRow in layout
          rowImagesCount = parseInt layoutRow
          rowImages = images[0...rowImagesCount]

          # We need to make the row as high as the smallest image (the one with smallest aspect ratio). We do this by
          # adjusting margins on images with higher aspect ratio, so that we see the middle part of those images.
          aspectRatios = for image in rowImages
            $image = $(image)

            # We have original image size stored in data attributes (so we don't have to wait for image to load).
            width = $image.data('width')
            height = $image.data('height')

            height / width

          minAspectRatio = _.min aspectRatios

          $group = $("<div class='group layout-#{rowImagesCount}'></div>")
          
          for image, index in rowImages
            $image = $("<div class='image'></div>")
            $image.append(image)
            aspectRatioDifference = aspectRatios[index] - minAspectRatio
            marginPercentage = "-#{aspectRatioDifference * 50}%"
            $(image).css
              marginTop: marginPercentage
              marginBottom: marginPercentage

            $group.append($image)

          images = images[rowImagesCount..]
          $photoset.append($group)

      # Create fullscreen image streams.
      @wireArtworkStreams $post

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
            $(paragraphs).wrapAll('<div class="paragraphs-block">')
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

      # Remove flavor text.
      $post.find('> blockquote > p > b > i, > blockquote > p > i > b').closest('blockquote').remove()

      # If this is a guest post, add author after the title.
      tags = ($(tag).text() for tag in $post.find('.tags .tag'))
      guestBlogIndex = _.indexOf tags, 'Guest Blog'

      if guestBlogIndex > -1
        author = tags[guestBlogIndex + 1]
        $post.find('h1').after("<div class='guest-blog-attribution'>Guest blog by #{author}</div>")

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

      # If there are no back issues, add the latest issue there.
      unless $('.back-issue').length
        $backIssue = $("""
          <li class="back-issue" data-page="1">
            <a class="link" href="#{Retronator.HQ.Items.Daily.BlogUrl}"><span class="text"></span></a>
          </li>
        """)

        $('.back-issues').each (index, backIssue) =>
          $(backIssue).append($backIssue.clone())

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

        $('.tag-ear .text').text(bestTag.tag) if bestTag

    else
      # We're on a permalink page.
      @isPermalinkPage = true
      @$newspaper.addClass('permalink')

      # Start on the inside.
      @$newspaper.addClass('inside').addClass('scroll-inside')

    # Now that the frontpage has been built, remove modifier tags.
    for tag in $('.post .tags .tag')
      $tag = $(tag)
      tagText = $tag.text()

      for modifier in ['cover', 'title']
        $tag.remove() if _.startsWith tagText, modifier

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

  processBlogData: (data) ->
    # Process blog info.
    $('.circulation .value').text(data.blogInfo.followers.toLocaleString Artificial.Babel.currentLanguage())

    # Process supporters messages.
    messages = _.sortBy data.supporterMessages, (message) -> -message.priority
    $messages = $('.supporters .messages')

    for message in messages
      $message = $("<li class='message'></li>")
      $message.append("<blockquote class='text'>#{message.message}</blockquote>")
      $message.append("<div class='name'>#{message.name}</div>") if message.name
      $messages.append($message)

    # Create supporters table.
    $supportersTable = $('.supporters .supporters-table')
    for supporter in data.supportersWithNames
      $supporter = $("<tr>")
      $supporter.append("<td class='name'>#{supporter.name}</td>")
      $supporter.append("<td class='amount'>#{supporter.amount}</td>")
      $supportersTable.append($supporter)

    # Create featured websites. Grab two random featured websites, except
    # the last one (Retronator Magazine, which should always be there).
    featuredWebsites = _.initial data.featuredWebsites

    while featuredWebsites.length > 2
      randomWebsite = featuredWebsites[_.random featuredWebsites.length - 1]
      featuredWebsites = _.without featuredWebsites, randomWebsite

    featuredWebsites.push _.last data.featuredWebsites

    $('.featured-websites-area').css
      height: "#{featuredWebsites.length * 50 + 140}rem"

    $featuredWebsites = $('.featured-websites')

    for website, index in featuredWebsites
      $website = $("<li class='website'></li>")
      $website.css
        top: "#{(index + 1) * 50}rem"

      $preview = $("<a class='preview' href='#{website.url}' target='_blank'><img class='image' src='#{website.previewImageUrl}'/></a>")

      # Displace the magazine a bit.
      $preview.css
        left: "#{Math.floor Math.random() * 7 - 3}rem"

      $website.append($preview)
      $featuredWebsites.append($website)
