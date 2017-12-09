HQ = Retronator.HQ

class HQ.Items.Daily.Theme
  constructor: ->
    # Is the theme running on Tumblr?
    @tumblr = false

    # Get blog info.
    if @tumblr
      $.getJSON 'https://hq.retronator.com/daily/info.json', (blogInfo) =>
        @processBlogInfo blogInfo

    else
      Retronator.Blog.getInfo (error, blogInfo) =>
        if error
          console.error error
          return

        @processBlogInfo blogInfo

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
    if @tumblr or true
      $(window).resize => @onResize()

    # Trigger it for the first size to initialize.
    @onResize()

    # Copy latest date to frontpage and about page.
    $('.frontpage .date').text $('.post:first .date .value').text()
    $('.about .date').text $('.post:first .date').text()

    # Build the headlines.
    @initializeHeadlineDesigns()
    @layoutFrontpageHeadlines()

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
