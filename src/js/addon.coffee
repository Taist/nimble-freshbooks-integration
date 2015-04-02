app = require './app'

React = require 'react'

DOMObserver = require './helpers/domObserver'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app

    app.init _taistApi

    observer = new DOMObserver()

    if location.href.match /freshbooks\.com\/apiEnable/i
      observer.waitElement 'a[name=token]', (elem) ->
        container = document.createElement 'div'
        container.className = 'reactContainer'
        parent = elem.parentNode
        parent.insertBefore container, parent.querySelector 'h3.section-header'
        reactPage = require './react/freshbooks/apiEnable'
        React.render reactPage( {} ), container

    console.log "STARTED ON #{location.host}"

module.exports = addonEntry
