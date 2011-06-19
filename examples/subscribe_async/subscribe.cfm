
<cffunction
	name="handleMessage"
	access="public"
	returntype="void"
	output="false"
	hint="I get invoked on each message broadcast over the subscribed channel.">
	
	<!--- Define arguments. --->
	<cfargument
		name="message"
		type="any"
		required="true"
		hint="I am the message broadcast over the currently subscribed channel."
		/>
		
	<!--- Add the message to the locally cached messages. --->
	<cfset arrayPrepend(
		application.messages,
		arguments.message
		) />
	
	<!--- Return out. --->
	<cfreturn />
</cffunction>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!DOCTYPE html>
<html>
<head>
	<title></title>
</head>
<body>
	
	<h1>
		SubscribeAsync()
	</h1>
	
	<p>
		This frame will be subscribing to the PubNub channel. As it 
		does, a callback will be invoked on each broadcast message
		that will add it to the locally-cached queue of messages.
	</p>
	
	<!--- 
		Subscribe to the given channel. As each message is returned, 
		it will be passed off to the given callback (which will add 
		it to the locally-cached queue).
	--->
	<cfset application.pubnub.subscribeAsync(
		channel = "coldfusion:subscribe_async",
		callback = handleMessage,
		timeout = 20
		) />
	
	<cfflush interval="1" />
	
	<!--- Sleep this thread for a while as the subscribe method is running. --->
	<cfset sleep( 20 * 1000 ) />
	
	<!--- Unsubscribe from the async subscribe. --->
	<cfset application.pubnub.unsubscribe() /> 
	
	<p>
		..... <strong style="color: red ;">Done listening to the channel</strong>.
	</p>
	
	<!--- Flag the application as no longer running. --->
	<cfset application.isRunning = false />
	
</body>
</html>
