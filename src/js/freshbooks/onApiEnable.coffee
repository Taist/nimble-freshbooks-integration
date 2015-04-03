app = require '../app'

module.exports = ->
  app.observer.waitElement 'a[name=token]', (elem) ->
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

    app.fbAPI.getCreds().then (creds) ->
      onPageCreds = getOnPageCreds()
      isIntegrationEnabled = ( onPageCreds.url is creds?.url and onPageCreds.token is creds?.token )

      React = require 'react'
      reactPage = require '../react/freshbooks/apiEnable'
      React.render reactPage( { action, isIntegrationEnabled }), container
