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

    # Wrap consecutive paragraphs into three-column format.
    $('.post').each (postIndex, element) =>
      paragraphs = []

      children = $(element).children()

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

    # Wire up changes that happen on resizes.
    if @tumblr
      $(window).resize => @onResize()

      # Trigger it for the first size to initialize.
      @onResize()

    # Copy latest date to frontpage and about page.
    $('.frontpage .date').text $('.post:first .date .value').text()
    $('.about .date').text $('.post:first .date').text()

    @$newspaper = $('.newspaper')

    # Build the headlines.
    @initializeHeadlineDesigns()
    @layoutFrontpageHeadlines()

    # Wire up back button, or remove it if using the one from adventure interface.
    if @tumblr
      $('.back-button').click (event) => @onBackButtonClick()

    else
      $('.back-button').remove()

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

  onBackButtonClick: ->
    if @$newspaper.hasClass('inside')
      # Figure out which post we're on (the one in the upper half of the screen).
      halfHeight = $(window).height() / 2
      currentPostIndex = 0

      for post, postIndex in $('.post')
        currentPostIndex = postIndex if $(post).position().top < halfHeight

      # Position frontpage so that the current post headline is in the middle.
      $headline = $('.frontpage .headline').eq(currentPostIndex)

      $frontpageScrollContent = $('.frontpage-area .scroll-content')
      headlineTop = $headline.offset().top + $frontpageScrollContent.scrollTop()

      $frontpageScrollContent.scrollTop headlineTop - halfHeight

      # Start transition.
      @$newspaper.removeClass('inside')

      setTimeout =>
        @$newspaper.removeClass('scroll-inside')
      ,
        1000
      
      return true
      
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
