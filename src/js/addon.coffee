app = require './app'

React = require 'react'

Q = require 'q'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.observer = new DOMObserver()

    if location.href.match /freshbooks\.com\/apiEnable/i
      require('./freshbooks/onApiEnable')()

    if location.href.match /bidsketch\.com\/account\/api_tokens/i
      require('./bidsketch/onApiTokens')()

    if location.host.match /nimble\.com/i
      Q.all [
        app.fbAPI.getCreds()
        app.bidsketchAPI.getCreds()    
      ]
      .then ->
        require('./nimble/onNimble')()

    console.log "STARTED ON #{location.host}"

module.exports = addonEntry
