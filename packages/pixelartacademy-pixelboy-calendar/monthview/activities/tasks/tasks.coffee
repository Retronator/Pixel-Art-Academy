AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Calendar.MonthView.Tasks extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Calendar.MonthView.Tasks'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  onCreated: ->
    super arguments...

    @icons = new ComputedField =>
      taskEntries = @data()
      icons = {}
      counts = {}

      for taskEntry in taskEntries
        continue unless taskClass = PAA.Learning.Task.getClassForId taskEntry.taskId

        icon = _.toLower taskClass.icon()
        counts[icon] ?= 0
        counts[icon]++

        icons["#{icon}#{counts[icon]}"] = true

      icons
