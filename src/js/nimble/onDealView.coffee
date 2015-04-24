app = require '../app'

dealViewContainer = null
dealViewEstimateTable = null

React = require 'react'

renderOnDealView = (options = {}) ->
  app.exapi.getCompanyData app.nimbleAPI.getDealIdFromUrl()
  .then (dealInfo) ->

    console.log dealInfo

    fbEstimateLink = app.fbAPI.getEstimateLink dealInfo?.freshBooksEstimateId
    bidsketchProposalViewLink = app.bidsketchAPI.getPDFLink dealInfo?.bidsketchProposalId
    bidsketchProposalEditLink = app.bidsketchAPI.getProposalOpeningSectionsLink dealInfo?.bidsketchProposalId

    reactPage = require '../react/nimble/dealView'
    React.render reactPage( alertMessage: options.alertMessage ), dealViewContainer

    estimateTableData =
      isSpinnerActive: options.isSpinnerActive

    reactComponent = require '../react/nimble/dealViewEstimateTable'

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
            bidsketchProposalViewLink: bidsketchProposalViewLink
            bidsketchProposalEditLink: bidsketchProposalEditLink
            isSpinnerActive: options.isSpinnerActive
            fbContactName: "#{response.estimate.first_name?.$t} #{response.estimate.last_name?.$t}"
          }

        else
          estimateTableData.error = app.getError response

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

        React.render reactComponent( estimateTableData ), dealViewEstimateTable

    else
      estimateTableData.onCreateEstimate = app.actions.onCreateEstimate
      React.render reactComponent( estimateTableData ), dealViewEstimateTable

      app.nimbleAPI.getDealInfo()
      .then (dealInfo) ->
        require('../nimble/prepareCompanyInfo') dealInfo
      .then (companyInfo) ->
        { companyAddress, companyMembers, contact } = companyInfo
        estimateTableData.companyMembers = companyMembers
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
