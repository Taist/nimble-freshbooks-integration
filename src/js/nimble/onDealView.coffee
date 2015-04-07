app = require '../app'

Q = require 'q'

onCreateEstimate = ->
  currentNimbleContact = null
  currentFBContact = null

  app.nimbleAPI.getDealContact()
  .then (contact) ->
    console.log 'nimble contact is ', contact
    unless contact?.fields?.email? and contact?.record_type is 'person'
      return Q.reject 'CONTACT_NOT_FOUND'

    app.exapi.getCompanyData contact.id
    .then (linkedClient) ->
      unless linkedClient
        console.log 'creating new freshBooks user'
        currentNimbleContact = contact
        client =
          first_name: $t: contact.fields['first name']?[0]?.value
          last_name: $t: contact.fields['last name']?[0]?.value
          organization: $t: contact.fields['parent company']?[0]?.value
          email: $t: contact.fields['email']?[0]?.value

        app.fbAPI.createClient client
        .then (response) ->

          if response.status is 'ok'
            clientId = response.client_id.$t
            app.exapi.setCompanyData currentNimbleContact.id, { freshBooksClientId: clientId }
            .then ->
              Q.resolve clientId
          else
            Q.reject response
      else
        console.log 'working with existed freshBooks user'
        Q.resolve linkedClient.freshBooksClientId

  .then (fbClientId) ->
    currentFBContact = fbClientId
    estimate =
      client_id: $t: fbClientId
    app.fbAPI.createEstimate estimate

  .then (response) ->

    if response.status is 'ok'
      dealId = app.nimbleAPI.getDealIdFromUrl()
      console.log dealId, response

      estimateId = response.estimate_id.$t
      app.exapi.setCompanyData dealId, {
        freshBooksClientId: currentFBContact
        freshBooksEstimateId: estimateId
      }

      fbEstimateLink = app.fbAPI.getEstimateLink estimateId
      window.open fbEstimateLink, '_blank'
    else
      Q.reject response

  .then () ->
    renderOnDealView isSpinnerActive: false

  .catch (error) ->
    app.actions.onNimbleError error

dealViewContainer = null
dealViewEstimateTable = null

renderOnDealView = (options = {}) ->
  app.exapi.getCompanyData app.nimbleAPI.getDealIdFromUrl()
  .then (dealInfo) ->

    fbEstimateLink = app.fbAPI.getEstimateLink dealInfo?.freshBooksEstimateId

    React = require 'react'
    reactData = {
      onCreateEstimate,
      fbEstimateLink,
      alertMessage: options.alertMessage
      isSpinnerActive: options.isSpinnerActive 
    }
    reactPage = require '../react/nimble/dealView'
    React.render reactPage( reactData ), dealViewContainer

    app.fbAPI.getEstimate dealInfo?.freshBooksEstimateId
    .then (response) ->

      if response?.status is 'ok'
        console.log response.estimate
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
        estimateTableData = null

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
