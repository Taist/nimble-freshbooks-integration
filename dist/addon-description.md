The addon saves a lot of time and effort on working with estimates and proposals via Nimble, Freshbooks and (optionally) Bidsketch:
* Freshbooks estimates can be created and viewed directly from Nimble; when an Estimate is created, a company attached to Deal is copied into Freshbooks;
* BidSketch proposals can be created and viewed directly from Nimble; again, the company from Nimble is copied to Bidsketch, and the proposal is filled with positions from the estimate.

Setting up the addon:
---------------------
* **Linking to Freshbooks**: after enabling the addon, open FreshBooks, go to "My Account -> FreshBooks API" - a large button "Enable integration with Nimble" will appear (see screenshot 1). Press it;
* **Linking to Bidsketch**:  open Bidsketch, go to *http://your_domain.bidsketch.com/account/api_tokens* (replace 'your_domain' with your domain name) - a list of tokens should appear with a button "LINK TO NIMBLE" near every active token; if the list is empty, press "NEW API TOKEN" first; press "LINK TO NIMBLE" near any token. 

Creating estimates:
-------------------
1. Open a deal in Nimble
2. Check that the deal is linked to a company that has the address filled and at least one person linked
3. Choose the person to receive the estimate in the new "Receiver" field and press "Create estimate". The receiver is chosen from the people linked to the company:
   * a new client will be created in Freshbooks (it will be associated with the company and person in Nimble)
   * a new estimate will be created in FreshBooks and opened for editing
   * the estimate contents will be displayed directly inside the deal in Nimble

Creating proposals:
-------------------
1. After the estimate was created, "Create proposal" button will appear
2. When pressed, it will create a proposal in Bidsketch and fill it with the estimate contents
3. A link to download the proposal in PDF will appear in Nimble both with a button to edit it in Bidsketch
