HQ = Retronator.HQ

class HQ.Items.Daily.Theme extends HQ.Items.Daily.Theme
  layoutFrontpageHeadlines: ->
    # Gather note counts from posts.
    notesCounts = _.map $('.post .notes-count'), (post) -> parseInt $(post).text()

    # Score them from 0-5.
    # 0: 0-10 (10)
    # 1: 10-40 (30)
    # 2: 40-100 (60)
    # 3: 100-250 (150)
    # 4: 250-500 (250)
    # 5: 500+
    #
    #      x ^ 0.4
    # y = ---------
    #        2.5

    postPowers = _.map notesCounts, (notesCount) -> Math.pow(notesCount, 0.4) / 2.5

    # Go over all possible design combinations.
    bestDesignScore = Infinity
    bestDesignIndices = null
    bestPowers = null

    iterateDesigns = (layoutIndex, designIndices, layoutPowers) =>
      if layoutPowers.length > postPowers.length
        # This layout sequence is longer than the number of posts so we can't use it.
        return

      # Calculate current score.
      delta = 0
      for layoutPower, index in layoutPowers
        delta += Math.abs layoutPower - postPowers[index]

      # If we're already worse, just quit.
      return if delta >= bestDesignScore

      if layoutPowers.length is postPowers.length
        # We've successfully covered all posts and we have the best score so far.
        bestDesignScore = delta
        bestDesignIndices = designIndices
        bestPowers = layoutPowers

      else
        # We need to add in some more designs. Just iterate over all.
        for design, designIndex in @headlineDesigns
          iterateDesigns layoutIndex + 1, designIndices.concat([designIndex]), layoutPowers.concat(design.powers)

    iterateDesigns 0, [], []

    # Apply designs in the layout sequence.
    $posts = $('.post')

    for designIndex in bestDesignIndices
      design = @headlineDesigns[designIndex]
      length = design.structure.length
      @applyDesign design, $posts[0...length]
      $posts = $posts[length..]

