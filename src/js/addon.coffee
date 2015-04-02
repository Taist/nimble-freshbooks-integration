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

        getOnPageCreds = ->
          url = document.querySelector('.api_creds p').innerText
          token = document.querySelector('#api_token').innerText
          { url, token }

        action = ->
          app.actions.setFreshBooksCreds getOnPageCreds()

        app.actions.getFreshBooksCreds().then (creds) ->
          onPageCreds = getOnPageCreds()
          isIntegrationEnabled = ( onPageCreds.url is creds?.url and onPageCreds.token is creds?.token )

          reactPage = require './react/freshbooks/apiEnable'
          React.render reactPage( { action, isIntegrationEnabled }), container

    console.log "STARTED ON #{location.host}"

module.exports = addonEntry
