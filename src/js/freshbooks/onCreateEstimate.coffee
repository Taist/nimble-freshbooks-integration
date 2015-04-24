app = require '../app'

Q = require 'q'

onCreateEstimate = (contactPersonId) ->
  currentFBContact = null

  app.nimbleAPI.getDealInfo()
  .then (dealInfo) ->

    require('../nimble/prepareCompanyInfo') dealInfo

  .then (companyInfo) ->
    { companyAddress, companyMembers, contact } = companyInfo

    app.exapi.getCompanyData contactPersonId

    .then (linkedClient) ->
      unless linkedClient?.freshBooksClientId?

        firstPerson = null

        companyMembers = companyMembers.filter (member) ->
          if member.id isnt contactPersonId
            true
          else
            firstPerson = member
            false

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
            app.exapi.updateCompanyData contactPersonId, { freshBooksClientId: clientId }
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

      estimateId = response.estimate_id.$t

      fbEstimateLink = app.fbAPI.getEstimateLink estimateId
      window.open fbEstimateLink, '_blank'

      app.exapi.updateCompanyData dealId, {
        freshBooksClientId: currentFBContact
        freshBooksEstimateId: estimateId
        contactPersonId: contactPersonId
      }
    else
      Q.reject response

module.exports = onCreateEstimate
