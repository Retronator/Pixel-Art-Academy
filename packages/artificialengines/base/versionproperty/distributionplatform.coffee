AB = Artificial.Base

class AB.DistributionPlatform extends AB.VersionProperty
  @Types =
    Web: 'Web'
    Steam: 'Steam'
    AppStore: 'AppStore'
    None: 'None'
  
  @initialize()
  
  if Meteor.isDesktop
    Meteor.startup =>
      availabilityPromises = []
      
      if Artificial.Telepathy.Steam
        availabilityPromises.push new Promise (resolve, reject) =>
          Tracker.autorun (computation) =>
            steamAvailable = Artificial.Telepathy.Steam.available()
            return unless steamAvailable?
            computation.stop()
            
            @setType @Types.Steam if steamAvailable
            resolve()
            
      await Promise.all availabilityPromises
      
      return if @type()
      @setType @Types.None
  
  else if Meteor.isClient
    @setType @Types.Web
