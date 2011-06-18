

<!--- Create an instance of our PubNub component with DEMO credentials. --->
<cfset pubnub = createObject( "component", "com.PubNub" ).init(
	publishKey = "demo",
	subscribeKey = "demo"
	) />
	
	
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Create a message to publish. --->
<cfset message = {} />
<cfset message[ "uuid" ] = createUUID() />
<cfset message[ "message" ] = "This is a test message from ColdFusion (#timeFormat( now(), 'hh:mm:ss TT' )#)." />

<!--- Publish the message. --->
<cfset response = pubnub.publish(
	channel = "coldfusion:hello_world",
	message = message
	) />
	
<h2>
	Publish Response
</h2>
	
<cfdump 
	var="#response#"
	label="Publish Response"
	/>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Get the history for our channel. --->
<cfset response = pubnub.history(
	channel = "coldfusion:hello_world",
	limit = 5
	) />
	
<h2>
	History Response
</h2>
	
<cfdump 
	var="#response#"
	label="History Response"
	/>