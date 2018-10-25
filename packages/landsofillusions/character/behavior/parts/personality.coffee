LOI = LandsOfIllusions

class LOI.Character.Behavior.Personality extends LOI.Character.Part
  @Factors: {}

  constructor: (@options) ->
    super arguments...

    return unless @options.dataLocation

    @factorPowers = new ComputedField =>
      # Calculate factor values based on traits.
      factorPowers = {}

      for factorIndex in [1..5]
        factorPowers[factorIndex] =
          positive: 0
          negative: 0

      for factorPart in @properties.factors.parts()
        for traitsPart in factorPart.properties.traits.parts()
          traitKey = traitsPart.properties.key.options.dataLocation()
          trait = @constructor.Trait.documents.findOne key: traitKey

          continue unless traitWeight = traitsPart.properties.weight.options.dataLocation()

          # Add 2 points to the primary factor.
          primaryFactorPower = trait.primaryFactor.sign * traitWeight

          if primaryFactorPower > 0
            factorPowers[trait.primaryFactor.type].positive += 2

          else if primaryFactorPower < 0
            factorPowers[trait.primaryFactor.type].negative += 2

          # Add 1 point to the secondary factor.
          secondaryFactorPower = trait.secondaryFactor.sign * traitWeight

          if secondaryFactorPower > 0
            factorPowers[trait.secondaryFactor.type].positive++

          else if secondaryFactorPower < 0
            factorPowers[trait.secondaryFactor.type].negative++

      factorPowers
    ,
      true

    @hasData = new ComputedField =>
      # Personality has data if at least one factor has a value.
      for factorIndex, factorPower of @factorPowers()
        return true if factorPower.positive or factorPower.negative

      false

    @mbtiPowers = new ComputedField =>
      factorPowers = @factorPowers()

      factorValues = {}

      for factorIndex in [1..5]
        combinedFactorPower = (factorPowers[factorIndex].positive - factorPowers[factorIndex].negative)
        factorValues[factorIndex] = _.clamp combinedFactorPower / 10, -1, 1

      ei: -0.74 * factorValues[1] + 0.03 * factorValues[5] - 0.03 * factorValues[2] + 0.08 * factorValues[3] - 0.16 * factorValues[4]
      sn: 0.10 * factorValues[1] + 0.72 * factorValues[5] + 0.04 * factorValues[2] - 0.15 * factorValues[3] + 0.06 * factorValues[4]
      tf: 0.19 * factorValues[1] + 0.02 * factorValues[5] + 0.44 * factorValues[2] - 0.15 * factorValues[3] - 0.06 * factorValues[4]
      jp: 0.15 * factorValues[1] + 0.30 * factorValues[5] - 0.06 * factorValues[2] - 0.49 * factorValues[3] - 0.11 * factorValues[4]
    ,
      true

    @mbti = new ComputedField =>
      mbtiPowers = @mbtiPowers()

      indicatorLetters = [
        if mbtiPowers.ei < 0 then 'E' else 'I'
        if mbtiPowers.sn < 0 then 'S' else 'N'
        if mbtiPowers.tf < 0 then 'T' else 'F'
        if mbtiPowers.jp < 0 then 'J' else 'P'
      ]

      indicatorLetters.join ''
    ,
      true

    @temperamentPowers = new ComputedField =>
      mbtiPowers = @mbtiPowers()

      temperament =
        explorer: mbtiPowers.jp * 2
        builder: -mbtiPowers.sn - mbtiPowers.jp
        director: -mbtiPowers.tf * 2
        negotiator: mbtiPowers.sn + mbtiPowers.tf

      temperament
    ,
      true

  destroy: ->
    super arguments...
    
    @factorPowers?.stop()
    @mbtiPowers?.stop()
    @mbti?.stop()
    @temperamentPowers?.stop()

  hasTrait: (traitKey) ->
    for factorPart in @properties.factors.parts()
      for traitsPart in factorPart.properties.traits.parts()
        return true if traitsPart.properties.key.options.dataLocation() is traitKey

    false

  traitsString: ->
    traitsStrings = []

    for factorIndex, factor of @constructor.Factors
      continue unless factorPart = @properties.factors.partsByOrder()[factor.options.type]

      traitsString = factorPart.properties.traits.toString()
      traitsStrings = traitsStrings.concat traitsString if traitsString?.length

    traitsStrings.join ', '
