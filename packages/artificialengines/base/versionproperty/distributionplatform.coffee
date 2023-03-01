AB = Artificial.Base

class AB.DistributionPlatform extends AB.VersionProperty
  @Types =
    Web: 'Web'
    Steam: 'Steam'
    AppStore: 'AppStore'
  
  @setType Meteor.settings.public.distributionPlatform or @Types.Web
