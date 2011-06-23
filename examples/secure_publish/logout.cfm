
<!--- Clear the logged-in flag on the user. --->
<cfset session.user.isLoggedIn = false />

<!--- 
	Now that the user has been logged-out, redirect the user 
	back to the index page. They will no longer be able to 
	publish messages.
--->
<cflocation
	url="./index.cfm"
	addtoken="false"
	/>
