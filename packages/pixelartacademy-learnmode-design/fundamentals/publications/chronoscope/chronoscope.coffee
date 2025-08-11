PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Publications.Chronoscope
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Publications.Chronoscope'
  
  @IssueIDs =
    ScienceFiction: "#{@id()}.ScienceFiction"

if Meteor.isClient
  PAA.Publication.Article.CustomClass.registerClass "chronoscope-cover-specialeditiontitle"
  PAA.Publication.Article.CustomClass.registerClass "chronoscope-cover-line chronoscope-cover-line-#{lineNumber}" for lineNumber in [1..2]
  PAA.Publication.Article.CustomClass.registerClass "chronoscope-tableofcontents-imprint"
