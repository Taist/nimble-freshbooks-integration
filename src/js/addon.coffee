app = require './app'

DOMObserver = require './helpers/domObserver'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app

    app.init _taistApi

    console.log "STARTED ON #{location.host}"

module.exports = addonEntry
