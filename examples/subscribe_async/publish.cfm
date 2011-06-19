
<!DOCTYPE html>
<html>
<head>
	<title></title>
	
	<!--- Refresh this page every few seconds (to broadcast a new message). --->
	<meta http-equiv="refresh" content="3" />
</head>
<body>
	
	<h1>
		I Publish A Message
	</h1>
	
	
	<!--- Check to see if the application is still running. --->
	<cfif application.isRunning>
		
		<!--- Create a message to publish. --->
		<cfset message = {
			uuid = createUUID(),
			text = "This is a message published at #timeFormat( now(), 'hh:mm:ss TT' )#."
			} />
		
		<!--- Broadcast the message. --->
		<cfset application.pubnub.publish(
			channel = "coldfusion:subscribe_async",
			message = message
			) />
		
		<p>
			I just published the message:
			
			<cfoutput>
				<strong>#message.text#</strong>
			</cfoutput>
		</p>
		
	<cfelse>
		
		<!--- No longer running. --->
		<p>
			..... <strong style="color: red ;">Application is no longer running</strong>. 
			<a href="./index.cfm" target="_top">Refresh</a>.
		</p>
		
	</cfif>
	
</body>
</html>
