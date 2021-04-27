AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Character extends LOI.Character
  @Meta
    name: @id()
    replaceParent: true

  @instances = {}
  
  @getInstance: (idOrDocument) ->
    id = idOrDocument?._id or idOrDocument
    return unless id
    
    unless @instances[id]
      Tracker.nonreactive =>
        @instances[id] = new @Instance id

    @instances[id]

  @agents = {}

  @getAgent: (id) ->
    unless @agents[id]
      Tracker.nonreactive =>
        @agents[id] = new @Agent id

    @agents[id]

  @getPerson: (id) ->
    if Match.test id, Match.DocumentId
      @getAgent id

    else
      LOI.adventure.getThing id

  @formatText: (text, keyword, character, onlyQualifiedPronouns) ->
    pronouns = character.avatar.pronouns()

    getPronoun = (key) =>
      LOI.adventure.parser.vocabulary.getPhrases("Pronouns.#{key}.#{pronouns}")?[0]

    text = text.replace new RegExp("_#{keyword}_", 'g'), (match) ->
      character.avatar.shortName()

    text = text.replace new RegExp("_#{_.toUpper keyword}_", 'g'), (match) ->
      _.toUpper character.avatar.shortName()

    text = text.replace new RegExp("_#{keyword}'s_", 'g'), (match) ->
      # TODO: Add a way to localize possession grammar.
      name = character.avatar.shortName()
      lastLetter = _.last name
      if lastLetter is 's' then "#{name}'" else "#{name}'s"

    for pronounPair in [
      ['they', 'Subjective']
      ['them', 'Objective']
      ['their', 'Adjective']
      ['theirs', 'Possessive']
      ['themselves', 'Reflexive']
    ]
      pronounReplacement = (match, pronounCase) ->
        pronoun = getPronoun pronounPair[1]

        if pronounCase is 'T' then pronoun = _.upperFirst pronoun

        pronoun

      unless onlyQualifiedPronouns
        # Do replacement on pronouns without a keyword qualifier.
        text = text.replace new RegExp("_(t|T)#{pronounPair[0].substring(1)}_", 'g'), pronounReplacement

      # Replace pronouns qualified with the keyword.
      text = text.replace new RegExp("_#{keyword}:(t|T)#{pronounPair[0].substring(1)}_", 'g'), pronounReplacement

    beSubstitution = (match) ->
      # We assume neutral pronouns use plural verbs.
      # TODO: Can we make this assumption? Probably depends on language's properties.
      numberCategory = if pronouns is LOI.Avatar.Pronouns.Neutral then 'Plural' else 'Singular'
      LOI.adventure.parser.vocabulary.getPhrases("Verbs.Be.Present.3rdPerson.#{numberCategory}")?[0]

    text = text.replace /_are_/g, beSubstitution unless onlyQualifiedPronouns
    text = text.replace new RegExp("_#{keyword}:are", 'g'), beSubstitution

    # TODO: Move this to an English-specific substitution class.
    presentSimpleSubstitution = (match, verb, suffix) ->
      if pronouns is LOI.Avatar.Pronouns.Neutral
        # Return just the verb without the suffix.
        verb

      else
        # The suffix is used.
        "#{verb}#{suffix}"

    text = text.replace /(\w+)_(e?s)/g, presentSimpleSubstitution unless onlyQualifiedPronouns
    text = text.replace new RegExp("#{keyword}:(\\w+)_(e?s)", 'g'), presentSimpleSubstitution

    text
