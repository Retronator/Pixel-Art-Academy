AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Progress
  constructor: (@options) ->
    @content = @options.content

    # By default the progress is related to the current profile.
    @options.profileId ?= => LOI.adventure.profileId()

    # Automatically update the progress entry after initialization has finished.
    Meteor.setTimeout =>
      return if @_destroyed

      @_upsertEntryAutorun = Tracker.autorun (computation) =>
        return unless LOI.adventureInitialized()

        # Only do it for currently active profile.
        return unless @options.profileId() is LOI.adventure.profileId()

        # Only do it when active.
        return unless @active()

        # Only make an entry if there was any progress.
        return unless completedRatio = @completedRatio()

        selector =
          contentId: @content.id()
          profileId: @options.profileId()

        entry = _.extend
          lastEditTime: new Date()
          completedRatio: completedRatio
        ,
          selector

        entry.completedUnitsCount = completedUnitsCount if completedUnitsCount = @completedUnitsCount?()
        entry.requiredCompletedRatio = requiredCompletedRatio if requiredCompletedRatio = @requiredCompletedRatio?()
        entry.requiredCompletedUnitsCount = requiredCompletedUnitsCount if requiredCompletedUnitsCount = @requiredCompletedRatio?()

        LM.Content.Progress.Entry.documents.upsert selector, entry

  destroy: ->
    @_upsertEntryAutorun?.stop()
    @_destroyed = true

  completed: -> throw new AE.NotImplementedException "Progress must provide if the content has been completed or not."
  completedRatio: -> throw new AE.NotImplementedException "Progress must provide the ratio towards full completion of the content."

  totalUnits: -> @options.totalUnits or @options.units
  requiredUnits: -> @options.requiredUnits or @options.units

  entry: ->
    @constructor.Entry.documents.findOne
      contentId: @content.id()
      profileId: @options.profileId()

  weight: -> @options.weight or 1

  active: ->
    # Content needs to be available and unlocked.
    return unless @content.available() and @content.unlocked()

    # Progress is active until it is 100%.
    @completedRatio() < 1
