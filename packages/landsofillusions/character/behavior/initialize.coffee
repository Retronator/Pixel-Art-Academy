LOI = LandsOfIllusions
Personality = LOI.Character.Behavior.Personality

Meteor.startup ->
  hues = LOI.Assets.Palette.Atari2600.hues

  _.extend Personality.Factors,
    1: new Personality.Factor
      typeNumber: 1
      type: 'PersonalityFactor1'
      positive:
        name: 'Energy'
        color: hue: hues.yellow, shade: 6
      negative:
        name: 'Peace'
        color: hue: hues.grey, shade: 6
      displayReversed: true

    2: new Personality.Factor
      typeNumber: 2
      type: 'PersonalityFactor2'
      positive:
        name: 'Cooperation'
        color: hue: hues.green, shade: 5
      negative:
        name: 'Independence'
        color: hue: hues.red, shade: 3

    3: new Personality.Factor
      typeNumber: 3
      type: 'PersonalityFactor3'
      positive:
        name: 'Order'
        color: hue: hues.blue, shade: 3
      negative:
        name: 'Spontaneity'
        color: hue: hues.magenta, shade: 5

    4: new Personality.Factor
      typeNumber: 4
      type: 'PersonalityFactor4'
      positive:
        name: 'Stability'
        color: hue: hues.cyan, shade: 5
      negative:
        name: 'Emotions'
        color: hue: hues.magenta, shade: 3

    5: new Personality.Factor
      typeNumber: 5
      type: 'PersonalityFactor5'
      positive:
        name: 'Progress'
        color: hue: hues.peach, shade: 4
      negative:
        name: 'Tradition'
        color: hue: hues.purple, shade: 3
      displayReversed: true

  lines = LOI.Character.Behavior.Personality.traitsData.split '\n'
  currentCategory = null

  for line in lines
    if currentCategory
      if line.length
        trait = _.extend
          name: line
        ,
          currentCategory

        LOI.Character.Behavior.Personality.Trait.documents.insert trait

      else
        # We've reached the end of the category.
        currentCategory = null

    else
      # Wait till we get an entry.
      continue unless line.length

      # The line contains the category signature.
      currentCategory =
        primaryFactor:
          type: parseInt line[0]
          sign: parseInt "#{line[1]}1"
        secondaryFactor:
          type: parseInt line[2]
          sign: parseInt "#{line[3]}1"
