LOI = LandsOfIllusions
Personality = LOI.Character.Behavior.Personality

# We can't use LOI.Assets since it comes from another package. We also can't wait for startup to happen since on
# startup a character already needs to be created and we need the factors to be initialized.
hues =
  grey: 0
  yellow: 1
  orange: 2
  peach: 3
  red: 4
  magenta: 5
  purple: 6
  indigo: 7
  blue: 8
  azure: 9
  cyan: 10
  aqua: 11
  green: 12
  lime: 13
  olive: 14
  brown: 15

_.extend Personality.Factors,
  1: new Personality.Factor
    type: 1
    positive:
      key: 'Energy'
      color: hue: hues.yellow, shade: 6
    negative:
      key: 'Peace'
      color: hue: hues.grey, shade: 6
    displayReversed: true

  2: new Personality.Factor
    type: 2
    positive:
      key: 'Cooperation'
      color: hue: hues.green, shade: 5
    negative:
      key: 'Independence'
      color: hue: hues.red, shade: 3

  3: new Personality.Factor
    type: 3
    positive:
      key: 'Order'
      color: hue: hues.blue, shade: 3
    negative:
      key: 'Spontaneity'
      color: hue: hues.magenta, shade: 5

  4: new Personality.Factor
    type: 4
    positive:
      key: 'Stability'
      color: hue: hues.cyan, shade: 5
    negative:
      key: 'Emotions'
      color: hue: hues.magenta, shade: 3

  5: new Personality.Factor
    type: 5
    positive:
      key: 'Progress'
      color: hue: hues.peach, shade: 4
    negative:
      key: 'Tradition'
      color: hue: hues.purple, shade: 3
    displayReversed: true
