
<!--- 
	Flag the user as being logged-in. This will enable them 
	to publish messages to the PubNub channel (via our secure 
	PUBLISH page). 
--->
<cfset session.user.isLoggedIn = true />

<!--- Redirect the user back to the index page. --->
<cflocation
	url="./index.cfm"
	addtoken="false"
	/>
