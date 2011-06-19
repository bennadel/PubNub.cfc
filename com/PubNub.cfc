
<cfcomponent
	output="false"
	hint="I provide a PubNub API functionality.">

	
	<cffunction
		name="init"
		access="public"
		returntype="any"
		output="false"
		hint="I return an initialized component.">
		
		<!--- Define arguments. --->
		<cfargument
			name="publishKey"
			type="string"
			required="true"
			hint="I am the key needed to publish messages. If your application is secure, do not make this key public (ie. available on the client)."
			/>
			
		<cfargument
			name="subscribeKey"
			type="string"
			required="true"
			hint="I am the key needed to subscribe to messages. This key is always public (ie. available on the client)."
			/>
			
		<cfargument
			name="secretKey"
			type="string"
			required="false"
			default=""
			hint="I am the optional key needed to sign messages being posted to the RESTful API - this key should never be shared. NOTE: This is only used for ENTERPRISE customers; it's use or non-use will have zero impact on regular PubNub accounts."
			/>
			
		<cfargument
			name="origin"
			type="string"
			required="false"
			default="pubsub.pubnub.com"
			hint="I am the domain used for the API end-point."
			/>
			
		<cfargument
			name="ssl"
			type="boolean"
			required="false"
			default="true"
			hint="I determine whether or not the RESTful posts should be made over a secure SSL connection."
			/>
			
		<!--- Store the properties. --->
		<cfset variables.publishKey = arguments.publishKey />
		<cfset variables.subscribeKey = arguments.subscribeKey />
		<cfset variables.secretKey = arguments.secretKey />
		<cfset variables.origin = arguments.origin />
		<cfset variables.ssl = arguments.ssl />
		
		<!--- 
			Set the API request protocol based on the current SSL
			configuration. 
		--->
		<cfif variables.ssl>
			<cfset variables.protocol = "https://" />
		<cfelse>
			<cfset variables.protocol = "http://" />		
		</cfif>
		
		<!--- 
			Set the limit to the number of characters that can be 
			posted in each message. If the user goes beyond this, the 
			message will be truncated. 
		--->
		<cfset variables.maxMessageLength = 1800 />
		
		<!--- Define the user-agent to be used in the HTTP requests. --->
		<cfset variables.userAgent = "ColdFusion/PubNub-Bot" />
		
		<!--- 
			This will keep track of the currently subscribed 
			asynchronous thread. 
		--->
		<cfset variables.asyncThreadName = "" />
		
		<!--- Return this object reference. --->
		<cfreturn this />
	</cffunction>
	
	
	<cffunction
		name="buildResource"
		access="public"
		returntype="string"
		output="false"
		hint="I construct the RESTful resource using the current origin and the given resource components.">

		<!--- Define arguments. --->
		<!---
			Any number of ** ORDERED ** arguments can be passed 
			through to this method. The resource will be constructed 
			from the given components.
		--->
		
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Before we construct the resource, we have to encode each 
			of the components. 
		--->
		<cfloop
			index="local.index"
			from="1"
			to="#arrayLen( arguments )#"
			step="1">
			
			<cfset arguments[ local.index ] = this.encodeResourceComponent(
				arguments[ local.index ]
				) />
			
		</cfloop>
		
		<!--- Build the resource. --->
		<cfset local.resource = (
			variables.protocol & 
			variables.origin & 
			"/" &
			arrayToList( arguments, "/" )
			) />

		<!--- Return the constructed API resource location. --->
		<cfreturn local.resource />
	</cffunction>
	
	
	<cffunction
		name="encodeResourceComponent"
		access="public"
		returntype="string"
		output="false"
		hint="I URL encode the given resource component.">
		
		<!--- Define arguments. --->
		<cfargument
			name="component"
			type="string"
			required="true"
			hint="I am the component being URL encoded."
			/>
		
		<!--- Use the default ColdFusion URL encoding. --->
		<cfset local.encodedComponent = urlEncodedFormat( arguments.component ) />
		
		<!--- 
			Unescape the dash (-). The Pub/Sub resources need to go 
			through unescaped. 
		--->
		<cfset local.encodedComponent = replaceNoCase(
			local.encodedComponent,
			"%2D",
			"-",
			"all"
			) />
		
		<!--- Return the encoded component. --->
		<cfreturn local.encodedComponent />
	</cffunction>
	
	
	<cffunction
		name="history"
		access="public"
		returntype="struct"
		output="false"
		hint="I get historical messages from the given channel.">
		
		<!--- Define arguments. --->
		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel for which we are getting historical messages."
			/>
			
		<cfargument
			name="limit"
			type="numeric"
			required="false"
			default="10"
			hint="I am the maximum number of historical messages to return (in time-ASCENDING order - oldest messages listed first)."
			/>
		
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- Build the API resource. --->
		<cfset local.resource = this.buildResource(
			"history",
			variables.subscribeKey,
			arguments.channel,
			"0",
			arguments.limit
			) />
			
		<!--- Get this historical message from the API. --->
		<cfhttp
			result="local.response"
			method="get"
			url="#local.resource#"
			useragent="#variables.userAgent#"
			/>
		
		<!--- Check to see if the request came back OK. --->
		<cfif !reFind( "2\d+", local.response.statusCode )>
			
			<!--- Throw an exception. --->
			<cfthrow
				type="HTTPFailure"
				message="The HTTP request made to the API was not succesful."
				detail="The HTTP request to the API returned with the status code #local.response.statusCode#."
				/>
		
		</cfif>
		
		<!--- Deserialize the response. --->
		<cfset local.apiResponse = deserializeJSON(
			toString( local.response.fileContent )
			) />
		
		<!--- Create a normalized response object. --->
		<cfset local.normalizedResponse = {
			isSuccess = isArray( local.apiResponse ),
			messages = local.apiResponse,
			errorMessage = ""
			} />
			
		<!--- 
			Check to see if the respones was an error (ie. not an 
			array). If so, then we need to clean our response. 
		--->
		<cfif !local.normalizedResponse.isSuccess>
		
			<!--- Clear the message. --->
			<cfset local.normalizedResponse.messages = [] />
			
			<!--- Set the error message. --->
			<cfset local.normalizedResponse.errorMessage = local.apiResponse />
		
		</cfif>
		
		<!--- Return the normalized response. --->
		<cfreturn local.normalizedResponse />
	</cffunction>
	

	<cffunction
		name="publish"
		access="public"
		returntype="struct"
		output="false"
		hint="I push the given message to the API.">
		
		<!--- Define arguments. --->
		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel to which the message will be posted (to all the clients subscribed to the same channel)."
			/>
			
		<cfargument
			name="message"
			type="any"
			required="true"
			hint="I am the message being posted. This will be serialized as JSON (no matter what you pass-in)."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- Serialize the messages as JSON. --->
		<cfset local.serializedMessage = serializeJSON( arguments.message ) />
		
		<!--- 
			Check to make sure the message is less than the max 
			message limit. If so, we will not be able to post it to 
			the API (or rather we would, but it would be truncated).
		--->
		<cfif (len( local.serializedMessage ) gt variables.maxMessageLength)>
		
			<!--- Message too long. --->
			<cfthrow
				type="InvalidMessageLength"
				message="The message you are posting is too long."
				detail="The message you are posting (once serialized) is of length #len( local.serializedMessage )#. Messages cannot be longer than #variables.maxMessageLength# characters."
				/>
		
		</cfif>
		
		<!--- 
			Check to see if we have a secret key, which can be used 
			to determine the signature of the request. 
		--->
		<cfif len( variables.secretKey )>
		
			<!--- Sign the resource components using the key. --->
			<cfset local.signature = this.signResourceComponents(
				variables.publishKey,
				variables.subscribeKey,
				variables.secretKey,
				arguments.channel,
				local.serializedMessage
				) />
		
		<cfelse>
		
			<!--- 
				No secret key was provided; use the default value for 
				the API signature. 
			--->
			<cfset local.signature = "0" />
		
		</cfif>
		
		<!--- Build the API resource. --->
		<cfset local.resource = this.buildResource(
			"publish",
			variables.publishKey,
			variables.subscribeKey,
			local.signature,
			arguments.channel,
			"0",
			local.serializedMessage
			) />
			
		<!--- Publish to the API. --->
		<cfhttp
			result="local.response"
			method="get"
			url="#local.resource#"
			useragent="#variables.userAgent#"
			/>
		
		<!--- Check to see if the request came back OK. --->
		<cfif !reFind( "2\d+", local.response.statusCode )>
			
			<!--- Throw an exception. --->
			<cfthrow
				type="HTTPFailure"
				message="The HTTP request made to the API was not succesful."
				detail="The HTTP request to the API returned with the status code #local.response.statusCode#."
				/>
		
		</cfif>
			
		<!--- 
			Deserialize the content of the response. This should come 
			back with an array that has two items:
			
			[ 1 ] == 1 : Sucecss
			[ 1 ] == 0 : Failure
			
			[ 2 ] == "D" : Demo success (based on demo keys).
			[ 2 ] == "S" : Success with valid key.
			[ 2 ] == "Error ..." : Error message.
		--->
		<cfset local.apiResponse = deserializeJSON(
			toString( local.response.fileContent )
			) />
			
		<!--- Create a normalized response object. --->
		<cfset local.normalizedResponse = {
			isSuccess = !!local.apiResponse[ 1 ],
			keyType = local.apiResponse[ 2 ],
			errorMessage = ""
			} />
			
		<!--- If it was an error, append the error message. --->
		<cfif !local.normalizedResponse.isSuccess>
		
			<!--- Set the error. --->
			<cfset local.normalizedResponse.errorMessage = local.apiResponse[ 2 ] />
			
			<!--- 
				Clear the key type (as this is not know in conjunction
				with an error). 
			--->
			<cfset local.normalizedResponse.keyType = "" />
		
		</cfif>
		
		<!--- Return the normalized response. --->
		<cfreturn local.normalizedResponse />
	</cffunction>


	<cffunction
		name="signResourceComponents"
		access="public"
		returntype="string"
		output="false"
		hint="I create an MD5 signature for the resource containing the given components.">
		
		<!--- Define arguments. --->
		<!---
			Any number of ** ORDERED ** arguments can be passed 
			through to this method. The resource will be constructed 
			from the given components and then hashed. 
		--->
		
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Build the resource using the ordered arguments as 
			individual path components.
		--->
		<cfset local.resource = arrayToList(
			arguments,
			"/"
			) />
		
		<!--- 
			Return the MD5 hash of the resource (the MD5 algorithm 
			in ColdFusion returns a fixed 32-character string).
		--->
		<cfreturn hash( local.resource ) />
	</cffunction>
	
	
	<cffunction
		name="subscribe"
		access="public"
		returntype="struct"
		output="false"
		hint="I get the latest messages from the given channel. I am very much like the history() method; however, I used a timeToken to determine where in the historical timeline of messages to gather broadcasts. If the timeToken is zero, I am not likely to return any messages.">
		
		<!--- Define arguments. --->
		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel to which we are subscribing."
			/>
		
		<cfargument
			name="timeToken"
			type="string"
			required="false"
			default="0"
			hint="I am the time token used to denote the last subscribed time. I'm not sure what this is used for; I assume it works like some sort of historical marker to know where the last known message was located."
			/>
		
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- Build the resource for the subscription. --->
		<cfset local.resource = this.buildResource(
			"subscribe",
			variables.subscribeKey,
			arguments.channel,
			"0",
			arguments.timeToken
			) />
	
		<!--- Subscribe to the channel. --->
		<cfhttp
			result="local.response"
			method="get"
			url="#local.resource#"
			useragent="#variables.userAgent#"
			/>
			
		<!--- Check to see if the request came back OK. --->
		<cfif !reFind( "2\d+", local.response.statusCode )>
			
			<!--- Throw an exception. --->
			<cfthrow
				type="HTTPFailure"
				message="The HTTP request made to the API was not succesful."
				detail="The HTTP request to the API returned with the status code #local.response.statusCode#."
				/>
		
		</cfif>
	
		<!--- 
			Deserialize the response. It should be an array with two items; 
			the first is the array of messages and the second is the new 
			timetoken:
			
			[ 1 ] = [ .. messages .. ]
			[ 2 ] = time token 
		--->
		<cfset local.apiResponse = deserializeJSON(
			toString( local.response.fileContent )
			) />
			
		<!--- Create a normalized response object. --->
		<cfset local.normalizedResponse = {
			messages = local.apiResponse[ 1 ],
			timeToken = local.apiResponse[ 2 ]
			} />
			
		<!--- Return the normalized response. --->
		<cfreturn local.normalizedResponse />
	</cffunction>
	
	
	<cffunction
		name="subscribeAsync"
		access="public"
		returntype="struct"
		output="false"
		hint="I subscribe to the given channel using an ASYNCHRONOUS THREAD. Only one channel can be subscribed at a time.">
		
		<!--- Define arguments. --->
		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel to which we are subscribing."
			/>
			
		<cfargument
			name="callback"
			type="any"
			required="true"
			hint="I am the user defined function (UDF) that will be invoked for each message broadcast in the subscribed channel."
			/>
			
		<cfargument
			name="timeout"
			type="numeric"
			required="false"
			default="0"
			hint="I am the number of seconds that this async subscribe functionality can run before it is automatically unsubsribes. This is here for safey when testing."
			/>
		
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- Create a new thread name for this channel subscribtion. --->
		<cfset variables.asyncThreadName = ("subscribe-" & hash( arguments.channel & getTickCount() )) />
		
		<!--- Start the thread. --->
		<cfthread
			action="run"
			name="#variables.asyncThreadName#"
			threadname="#variables.asyncThreadName#"
			timestarted="#now()#"
			subscribetimeout="#arguments.timeout#"	
			channel="#arguments.channel#"
			callback="#arguments.callback#">
			
			<!--- Store the callback locally. --->
			<cfset thread.callback = attributes.callback />
			
			<!--- Default the timetoken. --->
			<cfset thread.timeToken = "0" />
				
			<!--- Keep hitting the PubNub API until the thread is unsubscribed. --->
			<cfloop condition="true">
			
				<!--- 
					Check to see if the thread name matches the currently 
					subscribed channel.
					
					If a timeout is specified, this will also cause the loop to break
					if the timeout has elapsed.
				--->
				<cfif (
					(attributes.threadName neq variables.asyncThreadName) ||
					(
						attributes.subscribeTimeout && 
						(dateAdd( "s", attributes.subscribeTimeout, attributes.timeStarted ) lte now())
					))>
					
					<!--- This thread has been unsubscribed - kill it. --->
					<cfbreak />
				
				</cfif>
				
				<!--- Get the current messages. --->
				<cfset thread.messageResponse = this.subscribe(
					attributes.channel,
					thread.timeToken
					) />
				
				<cfset thread[ getTickCount() ] = thread.messageResponse />
				
				<!--- Store the new time token. --->
				<cfset thread.timeToken = thread.messageResponse.timeToken />
				
				<!--- Loop over the messages and invoke the callback on each. --->
				<cfloop
					index="thread.message"
					array="#thread.messageResponse.messages#">
					
					<cfset thread.callback( thread.message ) />
					
				</cfloop>
				
				<!--- Sleep the thread for a bit. --->
				<cfset sleep( 2 * 1000 ) />
				
			</cfloop>
			
		</cfthread>
		
		<!--- Return this object reference for method chaining. --->
		<cfreturn this />
	</cffunction>
	
	
	<cffunction
		name="time"
		access="public"
		returntype="any"
		output="false"
		hint="I return a standardized time (in milliseconds) as provided by PubNub. Due to the integer size limitations of ColdFusion, there is an option to return this value as a BigInt.">
		
		<!--- Define arguments. --->
		<cfargument
			name="returnAsBigInt"
			type="boolean"
			required="false"
			default="false"
			hint="I determine if the given time is returned as a BigInt Java object rather than as a string."
			/>
		
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- Build the API resource. --->
		<cfset local.resource = this.buildResource(
			"time",
			"0"
			) />
			
		<!--- Get the standardized time from the API. --->
		<cfhttp
			result="local.response"
			method="get"
			url="#local.resource#"
			useragent="#variables.userAgent#"
			/>
		
		<!--- Check to see if the request came back OK. --->
		<cfif !reFind( "2\d+", local.response.statusCode )>
			
			<!--- Throw an exception. --->
			<cfthrow
				type="HTTPFailure"
				message="The HTTP request made to the API was not succesful."
				detail="The HTTP request to the API returned with the status code #local.response.statusCode#."
				/>
		
		</cfif>
		
		<!--- 
			Since ColdFusion can't handle enormous integers, we are 
			going to parse the response as an integer string. The result
			can subsequently be returned as a BigInt if desired.
		--->
		<cfset local.timeAsString = reReplace( 
			local.response.fileContent, 
			"[^\d]+", 
			"", 
			"all"
			) /> 
		
		<!--- Check to see if a BigInt return is desired. --->
		<cfif arguments.returnAsBigInt>
		
			<!--- Return a big integer. --->
			<cfreturn createObject( "java", "java.math.BigInteger" ).init(
				javaCast( "string", local.timeAsString )
				) />
		
		<cfelse>
		
			<!--- Just return the value as a string. --->
			<cfreturn local.timeAsString />
		
		</cfif>
	</cffunction>
	
	
	<cffunction
		name="unsubscribe"
		access="public"
		returntype="any"
		output="false"
		hint="I unsubscribe from the current channel. Since only one channel can be subscribed at any one time, no channel needs to be specified. This applies mostly to the ASYNC subscribe method.">
		
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Clear the thread name. This is the best we can do since we 
			can't end the thread manually.
		--->
		<cfset variables.asyncThreadName = "" />
		
		<!--- Return this object reference for method chaining. --->
		<cfreturn this />
	</cffunction>

</cfcomponent>
