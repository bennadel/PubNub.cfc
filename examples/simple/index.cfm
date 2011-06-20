

<!--- 
	Create an instance of our PubNub component with DEMO credentials.
	This is an "account" that all people can use (but there is no
	privacy on it since everyone knows the keys). 
--->
<cfset pubnub = createObject( "component", "com.PubNub" ).init(
	publishKey = "demo",
	subscribeKey = "demo"
	) />
	
	
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->

	
<!--- 
	Get the current time token from PubNub. It uses a normalized,
	centralized timeline and can give you a time token in the number
	of milliseconds since the "zero" date. This will be used to for 
	the subscribe method call farther down. 
--->
<cfset timeToken = pubnub.time() />
	
	
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


<!--- 
	Get the history for our channel. This will return the most 
	recent [limit] items in time-ascending order. That is, the 
	oldest of the group is first, the newest of the group is last 
	in the array.
--->
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
	

<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- 
	Subscribe the given channel using the retreived time token 
	from above. This will return all the messages posted to the
	channel since the given time. This should include the broadcast 
	message from above. 
--->
<cfset response = pubnub.subscribe(
	channel = "coldfusion:hello_world",
	timeToken = timeToken
	) />
	
<h2>
	Subscribe Response
</h2>
	
<cfdump 
	var="#response#"
	label="Subscribe Response"
	/>
	
	
	