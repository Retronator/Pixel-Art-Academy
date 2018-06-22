LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.DrawingTutorial extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.DrawingTutorial'

  @location: -> PAA.Practice.Challenges.Drawing

  @initialize()

  destroy: ->
    super

    @_basics?.destroy()
    @_colors?.destroy()
    @_helpers?.destroy()

  things: ->
    # Player needs the Desktop editor selected for the tutorial to display.
    return [] unless PAA.PixelBoy.Apps.Drawing.state('editorId') is PAA.PixelBoy.Apps.Drawing.Editor.Desktop.id()

    @_basics ?= new C1.Challenges.Drawing.Tutorial.Basics

    things = [
      @_basics
    ]

    if @_basics.completed()
      @_colors ?= new C1.Challenges.Drawing.Tutorial.Colors
      @_helpers ?= new C1.Challenges.Drawing.Tutorial.Helpers

      things.push @_colors, @_helpers

    things
