HQ = Retronator.HQ

import ColorThief from 'colorthief'
colorThief = new ColorThief if Meteor.isClient and _.isFunction ColorThief

class HQ.Items.Daily.Theme extends HQ.Items.Daily.Theme
  initializeHeadlineDesigns: ->
    @headlineDesigns = []
    
    ###
    1   2   3   4   5   6
     ___________________   1
    |                   |
    |                   |
    |         A1        |
    |   /////////////   |  2
    |___//////A//////___|  3

    ###
    @headlineDesigns.push
      name: 'single-1'
      alternatives: ['', 'v']
      structure: [1]
      powers: [3]

    ###
    1   2   3   4   5   6
     ___________________   1
    |                   |
    |                   |
    |        A1         |
    |                   |
    |...................|  2
    |           ////////|
    |    A2     ////A///|
    |___________////////|  3

    ###
    @headlineDesigns.push
      name: 'single-2'
      alternatives: ['', 'h', 'v', 'vh']
      structure: [2]
      powers: [4]

    ###
    1   2   3   4   5   6
     ___________________   1
    |////////////  A2   |  2
    |           ........|  3
    |     A1    .       |
    |           .  A3   |
    |___________._______|  4

    ###
    @headlineDesigns.push
      name: 'single-3'
      alternatives: ['', 'h', 'v', 'vh']
      structure: [3]
      powers: [2.9]

    ###
    1         2         3
     ___________________   1
    |                   |
    |         A1        |
    |         __________|  2
    |////A////|////B////|  3
    |                   |
    |         B1        |
    |___________________|  4

    ###
    @headlineDesigns.push
      name: 'double-1'
      alternatives: ['', 'h']
      structure: [1, 1]
      powers: [3, 3]

    ###
    1   2   3   4   5   6
     ___________________   1
    |           ////A///|  2
    |           ////B///|  3
    |     A1    .       |
    |           .  B1   |
    |___________._______|  4

    ###
    @headlineDesigns.push
      name: 'double-2'
      alternatives: ['', 'h', 'v', 'vh']
      structure: [1, 1]
      powers: [3, 1.9]

    ###
    1   2   3   4   5   6
     ___________________   1
    |       ////|       |
    |       /A//|       |
    |   A   ////|   B   |  2
    |   1   |////   1   |
    |       |//B/       |
    |_______|////_______|  3

    ###
    @headlineDesigns.push
      name: 'double-3'
      alternatives: ['', 'h']
      structure: [1, 1]
      powers: [2, 2]

    ###
    1   2   3   4   5   6
     ___________________   1
    |           |       |
    |           |       |
    |     A1    |   B1  |  
    |           |       |  2
    |___////A///|///B///|  3

    ###
    @headlineDesigns.push
      name: 'double-4'
      alternatives: ['', 'h', 'v', 'vh']
      structure: [1, 1]
      powers: [2.9, 2]

    ###
    1   2   3   4   5   6
     ___________________   1
    |   A1  |/////B/////|  2
    |       |           |  3
    |///A///|           |  4
    |///C///|     B1    |  5
    |       |           |
    |___C1__|___________|  6

    ###
    @headlineDesigns.push
      name: 'triple-1'
      alternatives: ['', 'h', 'v', 'vh']
      structure: [1, 1, 1]
      powers: [2, 3, 2]

    ###
    1     2     3       4 
     ___________________   1
    |//A//|//B//|       |  2
    |     |     |       |
    |  A  |  B  |   C1  |  
    |  1  |  1  |       |  3
    |_____|_____|///C///|  4

    ###
    @headlineDesigns.push
      name: 'triple-2'
      alternatives: ['', 'h', 'v', 'vh']
      structure: [1, 1, 1]
      powers: [1, 1, 2]

    ###
    1     2       3     4 
     ___________________   1
    |//A//|       |//C//|  2
    |     |       |     |
    |  A  |   B1  |  C  |  
    |  1  |       |  1  |  3
    |_____|///B///|_____|  4

    ###
    @headlineDesigns.push
      name: 'triple-3'
      alternatives: ['', 'v']
      structure: [1, 1, 1]
      powers: [1, 2, 1]

  applyDesign: (design, posts, usedDesigns) ->
    # Find an alternative to use.
    usedAlternatives = usedDesigns[design.name]

    # Reset alternatives if we don't have them yet or if all alternatives have been used.
    unless usedAlternatives and usedAlternatives.length < design.alternatives.length
      usedAlternatives = []
      usedDesigns[design.name] = usedAlternatives
      
    possibleAlternatives = _.difference design.alternatives, usedAlternatives

    # Choose one of the alternatives in a random, but deterministic way. We use the posts text length.
    textLength = $(posts).text().length
    alternativeIndex = textLength % possibleAlternatives.length
    alternative = possibleAlternatives[alternativeIndex]
    usedAlternatives.push alternative

    $group = $("<div class='group #{design.name}#{alternative}'>")

    for headlineImagesCount, index in design.structure
      headlineStyleClassSuffix = ['a', 'b', 'c'][index]

      $post = $(posts[index])

      tags = ($(tag).text() for tag in $post.find('.tag'))
      titleModifierTag = _.find tags, (tag) => _.startsWith tag, 'title'
      coverModifierTag = _.find tags, (tag) => _.startsWith tag, 'cover'

      $images = $post.find('img')

      if coverModifierTag
        coverImageIndex = parseInt((coverModifierTag.match /cover(.*)/)[1]) - 1

      else
        coverImageIndex = 0

      coverImage = $images[coverImageIndex]
      restOfImages = _.without $images, coverImage

      postElements = []

      for headlineImageIndex in [1..headlineImagesCount]
        if headlineImageIndex is 1
          $sourceImage = $(coverImage)

        else
          imageIndex = Math.round (headlineImageIndex - 1) / (headlineImagesCount - 1) * (restOfImages.length - 1)
          $sourceImage = $(restOfImages[imageIndex])

        $image = $("<figure class='image image-#{headlineStyleClassSuffix}#{headlineImageIndex}'>")
        $image.append($sourceImage.clone())
        $image.css backgroundImage: "url('#{$sourceImage.attr('src')}')"
        $group.append($image)
        postElements.push $image[0]

      $headline = $("<div class='headline headline-#{headlineStyleClassSuffix}' data-index='#{$post.index()}'>")

      if titleModifierTag
        titleElementIndex = parseInt((titleModifierTag.match /title(.*)/)[1]) - 1

      else
        titleElementIndex = 0

      headlineTitle = $post.find('h1, b, strong, h2').eq(titleElementIndex).text()
      $headline.append("<div class='title'>#{headlineTitle}</div>")

      # We don't want the common and modifier tags to appear in the headlines.
      headlineTags = _.filter tags, (tag) =>
        not (tag in ['Feature', 'Pixel Art', 'Gaming', 'GIF', 'GIF Warning', 'Epilepsy Warning'] or _.startsWith(tag, 'cover') or _.startsWith(tag, 'title'))

      $headline.append("<div class='tags'>#{headlineTags.join ', '}</div>")

      # Apply headline colors.
      do (coverImage, $headline) =>
        applyColors = (colors) =>
          # Make sure some color contrast is present.
          colorDelta = (array1, array2) ->
            Math.abs(array1[0] - array2[0]) + Math.abs(array1[1] - array2[1]) + Math.abs(array1[2] - array2[2])

          return unless colorDelta(colors[0], colors[1]) > 50
          return unless colorDelta(colors[0], colors[2]) > 50

          createRGBColor = (array) => "rgb(#{array[0]},#{array[1]},#{array[2]})"

          $headline.css backgroundColor: createRGBColor colors[0]
          $headline.find('.title').css color: createRGBColor colors[1]
          $headline.find('.tags').css color: createRGBColor colors[2]

        if colorThief
          headlineImage = new Image
          headlineImage.crossOrigin = "Anonymous"
          headlineImage.onload = =>
            try
              applyColors colorThief.getPalette(headlineImage, 3)

          headlineImage.src = coverImage.src

        else
          ColorThief.getPalette(coverImage.src, 3).then(applyColors).catch (error) =>
            console.warn "Could not extract colors from headline image", coverImage.src, error

      $group.append($headline)
      postElements.push $headline[0]

      do ($post) =>
        $postElements = $(postElements)

        $postElements.mouseenter =>
          $postElements.addClass('hover')

        $postElements.mouseleave =>
          $postElements.removeClass('hover')

        $postElements.click (event) =>
          @goToInsideContent $post

    $('.headlines').append($group)

  goToInsideContent: ($target) ->
    # Don't allow to click before the transition is over.
    return if @$newspaper.hasClass('scroll-inside')

    # Start within the coverage of the frontpage.
    $frontpage = $('.frontpage')
    frontpageTop = $frontpage.offset().top
    frontpageBottom = frontpageTop + $frontpage.outerHeight()
    windowHeight = $(window).height()

    $insideContentArea = $('.inside-content-area')
    fadeTransition = false

    # Don't scroll past where the frontpage is so that the content doesn't appear through.
    if frontpageTop > 0
      # We need to maintain the top gap.
      frontpageScrollTop = $('.frontpage-area .scroll-content').scrollTop()
      scrollTop = Math.min scrollTop, frontpageScrollTop
      fadeTransition = true

    else if frontpageBottom < windowHeight
      # We have the bottom gap, so fade the content.
      fadeTransition = true

    if fadeTransition
      $insideContentArea.addClass('fade-transition')

    else
      $insideContentArea.removeClass('fade-transition')

    @$newspaper.addClass('inside').addClass('scroll-inside')

    # Scroll to post.
    $scrollContent = $('.inside-content-area .scroll-content')

    currentScrollTop = $scrollContent.scrollTop()
    postTop = $target.position().top
    scrollTop = postTop + currentScrollTop + 1

    $scrollContent.scrollTop scrollTop

