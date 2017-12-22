HQ = Retronator.HQ

class HQ.Items.Daily.Theme extends HQ.Items.Daily.Theme
  layoutFrontpageHeadlines: ->
    # Gather note counts from posts.
    posts = _.map $('.post'), (post) =>
      $post = $(post)
      notesCount = parseInt $post.find('.notes-count').text()

      notesCount: notesCount
      # Calculate power from 0-5 (and more).
      # 0: 0-25 (25)
      # 1: 25-100 (75)
      # 2: 100-220 (120)
      # 3: 220-400 (180)
      # 4: 400-620 (220)
      # 5: 620+
      #
      #      x ^ 0.5
      # y = ---------
      #        5
      power: Math.pow(notesCount, 0.5) / 5
      imagesCount: $post.find('img').length

    # TODO: Find a way to display posts without images. Right now we just remove them.
    posts = _.filter posts, (post) -> post.imagesCount
    return unless posts.length

    evaluateDesign = (designIndices, posts) =>
      # Create layout Powers.
      layoutPowers = []
      for designIndex in designIndices
        layoutPowers = layoutPowers.concat @headlineDesigns[designIndex].powers

      delta = 0
      for layoutPower, index in layoutPowers
        delta += Math.abs layoutPower - posts[index].power

      # Penalize for duplicate designs.
      designsUsed = {}
      designsUsed[designIndex] = true for designIndex in designIndices

      designsUsedCount = _.keys(designsUsed).length
      duplicates = designIndices.length - designsUsedCount

      delta + duplicates

    # Go over all possible design combinations.
    createDesign = (postPowers) =>
      bestDesignIndices = null
      bestDesignScore = Infinity

      # Go over all designs and see if any can cover the posts completely.
      for design, designIndex in @headlineDesigns
        # Make sure we are covering the exact amount of posts.
        continue unless design.powers.length is postPowers.length

        # Make sure the posts have enough images for the design.
        imageCheckOK = true

        for designImagesCount, postIndex in design.structure
          imageCheckOK = false unless postPowers[postIndex].imagesCount >= designImagesCount

        continue unless imageCheckOK

        designIndices = [designIndex]
        score = evaluateDesign designIndices, postPowers

        # Give a bonus for covering the posts with a wholesome design.
        score -= 1

        if score < bestDesignScore
          bestDesignScore = score
          bestDesignIndices = designIndices

      # Now also split the design in half (-/+1 to cover different split positions) and evaluate sub-designs.
      for splitDelta in [-1, 0, 1]
        firstHalfLength = Math.floor(postPowers.length / 2) + splitDelta

        # Nothing to do if the split is out of bounds.
        continue if firstHalfLength <= 0 or firstHalfLength >= postPowers.length

        firstHalf = postPowers[0...firstHalfLength]
        secondHalf = postPowers[firstHalfLength..]

        designIndices1 = createDesign firstHalf
        designIndices2 = createDesign secondHalf

        designIndices = [designIndices1..., designIndices2...]
        score = evaluateDesign designIndices, postPowers

        if score < bestDesignScore
          bestDesignScore = score
          bestDesignIndices = designIndices

      bestDesignIndices

    designIndices = createDesign posts

    # Apply designs in the layout sequence.
    $posts = $('.post')

    # TODO: Find a way to display posts without images. Right now we just remove them.
    $posts = $(_.filter $posts, (post) -> $(post).find('img').length)

    usedDesigns = {}

    for designIndex in designIndices
      design = @headlineDesigns[designIndex]
      length = design.structure.length
      @applyDesign design, $posts[0...length], usedDesigns
      $posts = $posts[length..]
