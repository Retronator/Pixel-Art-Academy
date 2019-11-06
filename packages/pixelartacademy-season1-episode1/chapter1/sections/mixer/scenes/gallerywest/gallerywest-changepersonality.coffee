LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends C1.Mixer.GalleryWest
  _changePersonality: (factorType, answerPosition) ->
    # Compare player's answer to character's actual factor score. Answer position is -1 for negative, +1 for positive desire.
    personality = LOI.character().behavior.part.properties.personality.part

    factorPowers = personality.factorPowers()
    factorDifference = factorPowers[factorType].positive - factorPowers[factorType].negative

    # We treat difference of 2 to -2 to be neutral.
    factorPosition = if factorDifference > 2 then 1 else if factorDifference < -2 then -1 else 0

    if factorPosition is answerPosition
      # No need to do any changes.
      return false

    personalityChanged = false

    # We need to change the character's personality. Unlink the personality if it's using a template.
    # TODO: Use the overriding system for applying changes on top of templates when it's implemented.
    if personality.options.dataLocation()?.template
      personality.options.dataLocation.unlinkTemplate()

    # We go over factor traits.
    factorTraits = LOI.Character.Behavior.Personality.Trait.documents.find(
      'primaryFactor.type': factorType
    ).fetch()

    # We want the representative trait first and the rest in a random order.
    representativeTraitIndex = _.findIndex factorTraits, (factorTrait) => factorTrait.secondaryFactor.type is factorType

    representativeTrait = factorTraits.splice(representativeTraitIndex, 1)[0]
    factorTraits = [representativeTrait, _.shuffle(factorTraits)...]

    factorPart = personality.properties.factors.getFactorPart factorType

    # Unlink the factor if it's using a template.
    # TODO: Use the overriding system for applying changes on top of templates when it's implemented.
    if factorPart.options.dataLocation()?.template
      factorPart.options.dataLocation.unlinkTemplate()

    ownedTraitParts = factorPart.properties.traits.parts()

    if answerPosition > factorPosition
      changeDirection = 1
      desiredFactorDifference = if answerPosition then 3 else -2

    else
      changeDirection = -1
      desiredFactorDifference = if answerPosition then -3 else 2

    changeNeeded = Math.abs(desiredFactorDifference - factorDifference)

    changeTrait = (trait, weight) =>
      # Apply the change after flush to wait for potential unlinking of templates to take place.
      Tracker.afterFlush =>
        factorPart.properties.traits.setTrait trait.key, weight

    for trait in factorTraits
      # Find the current weight of this trait (default is 0 if not present).
      ownedTraitPart = _.find ownedTraitParts, (traitsPart) => trait.key is traitsPart.properties.key.options.dataLocation()
      currentWeight = ownedTraitPart?.properties.weight.options.dataLocation() or 0

      # See how much the change is worth. Add 2 points to the primary factor, 1 to the secondary if same factor.
      potency = trait.primaryFactor.sign * 2
      potency += trait.secondaryFactor.sign if trait.secondaryFactor.type is factorType

      # See how the trait in different positions changes the factor.
      traitDelta = [
        potency * -1
        0
        potency
      ]

      # Compare to where currently the trait is and compute what change would it make to go to new position.
      currentDelta = traitDelta[currentWeight + 1]
      changeDelta = (delta - currentDelta for delta in traitDelta)

      # Test the middle position first since that will always make the smallest impact.
      if Math.sign(changeDelta[1]) is changeDirection and changeDelta[1] * changeDirection >= changeNeeded
        # Using the middle position will change things enough already.
        changeTrait trait, 0
        changeNeeded -= changeDelta[1] * changeDirection

      else if Math.sign(changeDelta[0]) is changeDirection
        # Using the left position will bring us closer.
        changeTrait trait, -1
        changeNeeded -= changeDelta[0] * changeDirection

      else if Math.sign(changeDelta[2]) is changeDirection
        # Using the right position will bring us closer.
        changeTrait trait, 1
        changeNeeded -= changeDelta[2] * changeDirection

      else
        # Neither position would bring us closer, go to next trait.
        continue

      personalityChanged = true

      # See if we've modified the personality enough.
      break if changeNeeded <= 0

    personalityChanged
