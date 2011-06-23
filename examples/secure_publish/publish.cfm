
<!--- 
	Since the client has to publish by going THROUGH the ColdFusion
	application, we can add any kind of server-side security that we 
	need to. In this case, we are just going to make sure the user is
	logged into the system.
--->
<cfif !session.user.isLoggedIn>

	<!--- Not authorized! --->
	<cfheader
		statuscode="401"
		statustext="Not Authorized"
		/>
		
	<h1>
		404 Not Found
	</h1>
		
	<!--- Halt processing of this template. --->
	<cfexit />

</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Param the form variables. --->
<cfparam name="form.uuid" type="string" />
<cfparam name="form.text" type="string" />

<!--- Construct the message object. --->
<cfset message = {} />
<cfset message[ "uuid" ] = form.uuid />
<cfset message[ "text" ] = form.text />


<!--- Publish the message to PubNub. --->
<cfset application.pubnub.publish(
	channel = "coldfusion:secure_publish",
	message = message
	) />

<!--- Return a success response. --->
<cfcontent
	type="application/json"
	variable="#toBinary( toBase64( 1 ) )#"
	/>
	