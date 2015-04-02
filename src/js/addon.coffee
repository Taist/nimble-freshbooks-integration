app = require './app'

React = require 'react'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.observer = new DOMObserver()

    if location.href.match /freshbooks\.com\/apiEnable/i
      require('./freshbooks/onApiEnable')()

    if location.host.match /nimble\.com/i
      require('./nimble/onNimble')()

    console.log "STARTED ON #{location.host}"

module.exports = addonEntry
