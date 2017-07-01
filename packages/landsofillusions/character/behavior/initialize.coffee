LOI = LandsOfIllusions
Personality = LOI.Character.Behavior.Personality

Meteor.startup ->
  hues = LOI.Assets.Palette.Atari2600.hues

  _.extend Personality.Factors,
    1: new Personality.Factor
      type: 'PersonalityFactor1'
      positive:
        name: 'Energy'
        color: hue: hues.yellow, shade: 6
      negative:
        name: 'Peace'
        color: hue: hues.grey, shade: 5
      displayReversed: true

    2: new Personality.Factor
      type: 'PersonalityFactor2'
      positive:
        name: 'Cooperation'
        color: hue: hues.green, shade: 4
      negative:
        name: 'Independence'
        color: hue: hues.red, shade: 3

    3: new Personality.Factor
      type: 'PersonalityFactor3'
      positive:
        name: 'Order'
        color: hue: hues.blue, shade: 3
      negative:
        name: 'Spontaneity'
        color: hue: hues.magenta, shade: 5

    4: new Personality.Factor
      type: 'PersonalityFactor4'
      positive:
        name: 'Stability'
        color: hue: hues.cyan, shade: 4
      negative:
        name: 'Emotions'
        color: hue: hues.magenta, shade: 3

    5: new Personality.Factor
      type: 'PersonalityFactor5'
      positive:
        name: 'Progress'
        color: hue: hues.peach, shade: 4
      negative:
        name: 'Tradition'
        color: hue: hues.purple, shade: 3
      displayReversed: true
