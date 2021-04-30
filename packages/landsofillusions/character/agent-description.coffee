AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

LOI.Character.Agent::description = ->
  translations = @translations()

  # Your character has a simple description.
  return translations.yourCharacter if @_id is LOI.characterId()

  # For other characters, generate a description from personality traits, age, and pronouns.
  description = LOI.Character.formatText @thingAvatar.description(), 'person', @instance

  # Generate characteristic personality adjectives. We use two from the energy/peace and cooperation/independence
  # factors, since they are the most descriptive of externally perceivable traits (the other factors are more
  # introspective. To choose which two, we use indices based on the character ID so they will always stay the same
  # for the same person (as long as their personality is the same).
  personalityPart = @instance.behavior.part.properties.personality.part

  traits = []

  for type in [1..2]
    factorTraits = personalityPart.properties.factors.partsByOrder()[type].traitsString().toLowerCase()
    continue unless factorTraits.length

    traits.push factorTraits.split(', ')...

  chosenTraits = []
  name = @instance.avatar.fullName()

  while traits.length > 0 and chosenTraits.length < 2
    characterIndex = chosenTraits.length % name.length
    index = name.charCodeAt(characterIndex) % traits.length
    chosenTraits.push traits[index]
    traits.splice index, 1

  # If no traits were found, add the mysterious trait.
  chosenTraits.push translations.mysterious unless chosenTraits.length
  personalityAdjectives = chosenTraits.join ', '

  # Start the descriptor with an age adjective.
  descriptorParts = []

  if age = @instance.document().profile?.age
    if age < 20
      descriptorParts.push translations.teenage

    else if age < 30
      descriptorParts.push translations.youngAdult

    else if age > 50
      descriptorParts.push translations.older

  # The main descriptor noun is based on the pronouns.
  descriptorField = 'person'

  pronouns = @instance.avatar.pronouns()

  unless pronouns is LOI.Avatar.Pronouns.Neutral
    if age and age < 20
      descriptorField = if pronouns is LOI.Avatar.Pronouns.Feminine then 'girl' else 'boy'

    else
      descriptorField = if pronouns is LOI.Avatar.Pronouns.Feminine then 'woman' else 'man'

  descriptorParts.push translations[descriptorField]

  descriptor = descriptorParts.join ' '

  description = description.replace '{{personalityAdjectives}}', AB.Rules.English.addIndefinitePronoun personalityAdjectives
  description = description.replace '{{descriptor}}', descriptor

  # Add neutral pronouns tip at the end.
  if pronouns is LOI.Avatar.Pronouns.Neutral
    description = "#{description} #{translations.neutralPronounsTip}"

  # Return the generated description.
  description
