app = require '../app'

Q = require 'q'

onCreateEstimate = ->
  currentNimbleContact = null
  currentFBContact = null

  app.nimbleAPI.getDealInfo()
  .then (dealInfo) ->

    require('../nimble/prepareCompanyInfo') dealInfo

  .then (companyInfo) ->
    { companyAddress, companyMembers, primaryContactId, contact } = companyInfo

    app.exapi.getCompanyData primaryContactId

    .then (linkedClient) ->
      console.log companyMembers

      unless linkedClient
        currentNimbleContact = contact

        firstPerson = companyMembers.shift()

        client =
          first_name: $t: firstPerson.first_name
          last_name: $t: firstPerson.last_name
          email: $t: firstPerson.email
          organization: $t: contact.fields['company name']?[0]?.value

          p_street1: $t: companyAddress.street
          p_city: $t: companyAddress.city
          p_state: $t: companyAddress.state
          p_country: $t: companyAddress.country
          p_code: $t: companyAddress.zip

        additionalContacts = companyMembers
          .filter (member) ->
            member.email?
          .map (member) ->
            first_name: $t: member.first_name
            last_name: $t: member.last_name
            email: $t: member.email

        if additionalContacts.length
          client.contacts = contact: additionalContacts

        console.log 'creating new freshBooks client', client

        app.fbAPI.createClient client
        .then (response) ->

          if response.status is 'ok'
            clientId = response.client_id.$t
            app.exapi.updateCompanyData currentNimbleContact.id, { freshBooksClientId: clientId }
            .then ->
              Q.resolve clientId
          else
            Q.reject response
      else
        console.log 'working with existed freshBooks user'
        Q.resolve linkedClient.freshBooksClientId

  .then (fbClientId) ->
    console.log "create estimate for client #{fbClientId}"
    currentFBContact = fbClientId
    estimate =
      client_id: $t: fbClientId
    app.fbAPI.createEstimate estimate

  .then (response) ->

    if response.status is 'ok'
      dealId = app.nimbleAPI.getDealIdFromUrl()
      console.log dealId, response

      estimateId = response.estimate_id.$t

      fbEstimateLink = app.fbAPI.getEstimateLink estimateId
      window.open fbEstimateLink, '_blank'

      app.exapi.updateCompanyData dealId, {
        freshBooksClientId: currentFBContact
        freshBooksEstimateId: estimateId
      }
    else
      Q.reject response

module.exports = onCreateEstimate
