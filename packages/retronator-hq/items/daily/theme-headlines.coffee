HQ = Retronator.HQ

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
      structure: [1, 1, 1]
      powers: [1, 3, 1]

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
      structure: [1, 1, 1]
      powers: [1, 2, 1]

  applyDesign: (design, posts) ->
    $group = $("<div class='group #{design.name}'>")

    for headlineImagesCount, index in design.structure
      headlineLetter = ['a', 'b', 'c'][index]
      $post = $(posts[index])
      images = $post.find('img')

      postElements = []

      for headlineImageIndex in [1..headlineImagesCount]
        if headlineImagesCount is 1
          imageIndex = 0

        else
          imageIndex = Math.round (headlineImageIndex - 1) / (headlineImagesCount - 1) * (images.length - 1)

        $image = $("<figure class='image image-#{headlineLetter}#{headlineImageIndex}'>")
        $sourceImage = $(images[imageIndex])
        $image.append($sourceImage.clone())
        $image.css backgroundImage: "url('#{$sourceImage.attr('src')}')"
        $group.append($image)
        postElements.push $image[0]

      $headline = $("<div class='headline headline-#{headlineLetter}'>")

      headlineTitle = $post.find('b').eq(0).text()
      $allTags = $post.find('.tag')

      # We don't want the common tags to appear in the headlines.
      headlineTags = _.filter $allTags, (tag) => not ($(tag).text() in ['Feature', 'Pixel Art', 'Gaming', 'GIF'])
      headlineTags = _.map headlineTags, (tag) => $(tag).text()

      $headline.append("<div class='title'>#{headlineTitle}</div>")
      $headline.append("<div class='tags'>#{headlineTags.join ', '}</div>")
      $group.append($headline)
      postElements.push $headline[0]

      do ($post) =>
        $(postElements).click (event) =>
          # Don't allow to click before the transition is over.
          return if @$newspaper.hasClass('scroll-inside')

          # Scroll to post.
          $scrollContent = $('.inside-content-area .scroll-content')

          currentScrollTop = $scrollContent.scrollTop()
          postTop = $post.position().top
          scrollTop = postTop + currentScrollTop + 1

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

          else if frontpageBottom < windowHeight
            # We have the bottom gap, so fade the content.
            fadeTransition = true

          if fadeTransition
            $insideContentArea.addClass('fade-transition')

          else
            $insideContentArea.removeClass('fade-transition')

          $scrollContent.scrollTop scrollTop

          @$newspaper.addClass('inside').addClass('scroll-inside')

    $('.headlines').append($group)
