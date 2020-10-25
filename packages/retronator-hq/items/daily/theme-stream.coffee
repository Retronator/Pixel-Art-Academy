HQ = Retronator.HQ

class HQ.Items.Daily.Theme extends HQ.Items.Daily.Theme
  wireArtworkStreams: ($post) ->
    # Get all the images, but skip the ones in links.
    images = $post.find('img').filter((index, image) =>
      not $(image).closest('.link').length
    ).toArray()
    return unless images.length

    # Split images into arrays of consecutive siblings. We start building the first group with the first image.
    currentGroup = [images[0]]
    groups = [currentGroup]
    images = images[1..]
    post = $post[0]

    while images.length
      lastImage = _.last currentGroup
      newImage = images[0]
      images = images[1..]

      # Are they siblings? We test the relation by being in sibling (or same) trees on post level.
      lastParent = lastImage
      lastParent = lastParent.parentNode until lastParent.parentNode is post

      newParent = newImage
      newParent = newParent.parentNode until newParent.parentNode is post

      if newParent in [lastParent, lastParent.nextSibling]
        # This is a sibling, add it to the same group.
        currentGroup.push newImage

      else
        # This is not a sibling, create a new group.
        currentGroup = [newImage]
        groups.push currentGroup

    for group in groups
      @wireArtworkStream $(group)

  wireArtworkStream: ($images) ->
    $images.click (event) =>
      noCursor = true
      $stream = $("<div class='pixelartdatabase-components-stream retronator-hq-items-daily-stream no-cursor'>")

      getCurrentArtworkAreaIndex = =>
        # Analyze on which image are we.
        halfHeight = $(document).height() / 2
        currentArtworkAreaIndex = 0

        for artworkArea, artworkAreaIndex in $stream.find('.artwork-area')
          currentArtworkAreaIndex = artworkAreaIndex if $(artworkArea).position().top < halfHeight

        currentArtworkAreaIndex

      # Handle closing off the stream.
      closeStream = =>
        $image = $images.eq(getCurrentArtworkAreaIndex())
        $insideContentScrollContent = $('.inside-content-area .scroll-content')
        @centerElement $image, $insideContentScrollContent

        $(document).off '.retronator-hq-items-daily-stream'
        
        $stream.remove()

        # Restore menu on escape.
        LandsOfIllusions.adventure.menu.customShowMenu null unless @tumblr

      $stream.click (event) => closeStream()

      $artworks =  $("<ol class='artworks'>")

      for image, index in $images
        startIndex = index if image is event.target

        $artworks.append """
          <li class="artwork-area">
            <figure class="artwork-with-caption">
              <div class="artwork-frame">
                <img class="artwork visible" src="#{image.src}"/>
              </div>
            </figure>
            <img class="background visible" src="#{image.src}"/>
          </li>
        """

      $stream.append($artworks)
      $('body').append($stream)

      centerArtwork = (index) =>
        $artworks = $stream.find('.artwork')
        index = Math.max 0, Math.min $artworks.length - 1, index
        $artwork = $artworks.eq(index)
        @centerElement $artwork, $stream

      $(document).on 'keydown.retronator-hq-items-daily-stream', (event) =>
        switch event.which
          when 37, 38 then delta = -1
          when 39, 40 then delta = 1
          when 27
            closeStream()
            return

        centerArtwork getCurrentArtworkAreaIndex() + delta

        # Hide the cursor since we're moving with keys.
        $stream.addClass('no-cursor')
        noCursor = true

      # Prevent menu opening on escape.
      unless @tumblr
        LandsOfIllusions.adventure.menu.customShowMenu => # Dummy function so nothing happens.

      # Show cursor when user moves the mouse.
      $(document).on 'mousemove.retronator-hq-items-daily-stream', (event) =>
        return unless noCursor

        $stream.removeClass('no-cursor')
        noCursor = false

      centerArtwork startIndex

  centerElement: ($element, $scrollContainer) ->
    # Scroll container so that the element is in the middle.
    elementMiddle = $element.offset().top + $element.height() / 2 - $scrollContainer.offset().top + $scrollContainer.scrollTop()
    screenMiddle = $(document).height() / 2

    $scrollContainer.scrollTop elementMiddle - screenMiddle
