
<!--- Flag the application as running. --->
<cfset application.isRunning = true />

<!DOCTYPE html>
<html>
<head>
	<title>PubNub Asynchronous Subscribe Demo</title>
</head>
<frameset rows="60%,20%,20%">
	<frame src="./messages.cfm" />
	<frame src="./publish.cfm" />
	<frame src="./subscribe.cfm" />
</frameset>
</html>
