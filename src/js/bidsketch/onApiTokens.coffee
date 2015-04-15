app = require '../app'

getOnPageCreds = (row) ->
  url = 'https://' + location.host
  token = row.querySelector('td').innerText
  { url, token }

onSetCreds = (row) ->
  app.actions.setBidsketchCreds getOnPageCreds row

module.exports = ->
  app.observer.waitElement '.inside tr', (row) ->
    nextColumn = row.querySelector('td:nth-child(2),th:nth-child(2)')

    container = document.createElement nextColumn.tagName
    container.className = 'reactContainer'
    container.style.width = '200px'

    row.insertBefore container, nextColumn

    if nextColumn.tagName.match /td/i

      app.bidsketchAPI.getCreds().then (creds) ->
        onPageCreds = getOnPageCreds row
        isIntegrationEnabled = ( onPageCreds.url is creds?.url and onPageCreds.token is creds?.token )

        action = ->
          onSetCreds row

        React = require 'react'
        reactPage = require '../react/bidsketch/apiTokens'
        React.render reactPage( { action, isIntegrationEnabled }), container
      .catch (error) ->
        console.log error
