app = require '../app'

dealViewContainer = null
dealViewEstimateTable = null

React = require 'react'

renderOnDealView = (options = {}) ->
  app.exapi.getCompanyData app.nimbleAPI.getDealIdFromUrl()
  .then (dealInfo) ->

    fbEstimateLink = app.fbAPI.getEstimateLink dealInfo?.freshBooksEstimateId

    reactData = {
      onCreateEstimate: app.actions.onCreateEstimate
      fbEstimateLink: fbEstimateLink
      alertMessage: options.alertMessage
      isSpinnerActive: options.isSpinnerActive
    }
    reactPage = require '../react/nimble/dealView'
    React.render reactPage( reactData ), dealViewContainer

    estimateTableData = null
    reactComponent = require '../react/nimble/dealViewEstimateTable'
    React.render reactComponent( estimateTableData ), dealViewEstimateTable

    if dealInfo?.freshBooksEstimateId?
      app.fbAPI.getEstimate dealInfo?.freshBooksEstimateId
      .then (response) ->

        if response?.status is 'ok'

          estimateTableData = {
            amount: response.estimate?.amount.$t
            currency: response.estimate?.currency_code.$t
            number: response.estimate?.number.$t
            time: (response.estimate?.lines?.line or []).filter (line) ->
              line?.name?.$t? and line?.type?.$t is 'Time'
            item: (response.estimate?.lines?.line or []).filter (line) ->
              line?.name?.$t? and line?.type?.$t isnt 'Time'
            fbEstimateLink: fbEstimateLink
          }

        else
          estimateTableData = { error: app.getError response }

        estimateTableData.onCreateProposal = ->
          app.actions.onCreateProposal {
            id: app.nimbleAPI.getDealIdFromUrl()
            info: dealInfo
            name: document.querySelector('.dealMainFieldTitle').innerText
            currency: response.estimate?.currency_code.$t
            fees:
              time: estimateTableData.time
              item: estimateTableData.item
          }

        reactComponent = require '../react/nimble/dealViewEstimateTable'
        React.render reactComponent( estimateTableData ), dealViewEstimateTable

  .catch (error) ->
    app.actions.onNimbleError error

module.exports = (options) ->
  unless dealViewContainer
    app.observer.waitElement '.DealView .profileInfoWrapper', (elem) ->

      dealViewContainer = document.createElement 'div'
      elem.querySelector('td.generalInfo').appendChild dealViewContainer

      dealViewEstimateTable = document.createElement 'div'
      elem.insertBefore dealViewEstimateTable, elem.querySelector('.fullInfoContainer')

      renderOnDealView options
  else
    renderOnDealView options
