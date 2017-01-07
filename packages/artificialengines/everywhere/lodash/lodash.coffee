# Replace underscore with Lo-Dash.
_ = lodash

if Meteor.isClient
  window.lodash = lodash
