HQ = Retronator.HQ

class HQ.Items.Daily.Theme extends HQ.Items.Daily.Theme
  wireArtworkStream: ($images) ->
    $images.click (event) =>
      $stream = $("<div class='pixelartdatabase-components-stream retronator-hq-items-daily-stream'>")

      getCurrentArtworkAreaIndex = =>
        # Analyze on which image are we.
        halfHeight = $(window).height() / 2
        currentArtworkAreaIndex = 0

        for artworkArea, artworkAreaIndex in $stream.find('.artwork-area')
          currentArtworkAreaIndex = artworkAreaIndex if $(artworkArea).position().top < halfHeight

        currentArtworkAreaIndex

      # Handle closing off the stream.
      $stream.click (event) =>
        $image = $images.eq(getCurrentArtworkAreaIndex())
        $insideContentScrollContent = $('.inside-content-area .scroll-content')
        @centerElement $image, $insideContentScrollContent

        $(window).off '.retronator-hq-items-daily-stream'
        
        $stream.remove()

      $artworks =  $("<ol class='artworks'>")

      for image, index in $images
        startIndex = index if image is event.target

        $artworks.append """
          <li class="artwork-area">
            <figure class="artwork-with-caption">
              <div class="artwork-frame">
                <img class="artwork" src="#{image.src}"/>
              </div>
            </figure>
            <img class="background" src="#{image.src}"/>
          </li>
        """

      $stream.append($artworks)
      $('body').append($stream)

      centerArtwork = (index) =>
        $artworks = $stream.find('.artwork')
        index = Math.max 0, Math.min $artworks.length - 1, index
        $artwork = $artworks.eq(index)
        @centerElement $artwork, $stream

      $(window).on 'keydown.retronator-hq-items-daily-stream', (event) ->
        switch event.which
          when 37, 38 then delta = -1
          when 39, 40 then delta = 1

        centerArtwork getCurrentArtworkAreaIndex() + delta

      centerArtwork startIndex

  centerElement: ($element, $scrollContainer) ->
    # Scroll container so that the element is in the middle.
    elementMiddle = $element.offset().top + $element.height() / 2 - $scrollContainer.offset().top + $scrollContainer.scrollTop()
    screenMiddle = $(window).height() / 2

    $scrollContainer.scrollTop elementMiddle - screenMiddle
