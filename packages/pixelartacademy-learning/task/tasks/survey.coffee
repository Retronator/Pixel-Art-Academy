AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy

class PAA.Learning.Task.Survey extends PAA.Learning.Task
  @type: -> 'Survey'

  @QuestionType:
    MultipleChoice: 'MultipleChoice'

  @questions: -> throw new AE.NotImplementedException "You must provide survey questions."

  @initialize: ->
    super arguments...
    
    # On the server, create this survey's translations.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()
        
        for question in @questions()
          AB.createTranslation translationNamespace, "survey.#{question.key}", question.prompt
          
          if question.type is @QuestionType.MultipleChoice
            for choice in question.choices
              AB.createTranslation translationNamespace, "survey.#{question.key}.#{choice.key}", choice.answer
