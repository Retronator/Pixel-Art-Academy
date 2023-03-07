lodash = require 'lodash'

# Replace underscore with Lo-Dash.
_ = lodash

if Meteor.isClient
  window["_"] = lodash
