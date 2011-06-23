
<cfoutput>

	<!DOCTYPE html>
	<html>
	<head>
		<title>Secure PubNub Publish ColdFusion Demo</title>
		
		<!-- jQuery. -->
		<script type="text/javascript" src="./linked/jquery-1.6.1.min.js"></script>
		
		<!-- 
			Include PubNub from THEIR content delivery netrwork. In 
			the documentation, they recommend this as the only way to 
			build things appropriately; it allows them to continually 
			update the security features.
			
			The ID and the SUB-KEY attributes of this script tag are 
			used to configure the PUBNUB JavaScript wrapper. 
			
			Notice that I am including the SUB-KEY but that I am NOT
			including the PUB-KEY. This will allow the client to 
			subscribe to the PubNub API, but will refurese any 
			attempts to publish directly to the PubNub API. 
		-->
		<script 
			id="pubnub"
			type="text/javascript" 
			src="http://cdn.pubnub.com/pubnub-3.1.min.js"
			sub-key="sub-f4baaac5-87e0-11e0-b5b4-1fcb5dd0ecb4"
			ssl="off">
		</script>
		
	</head>
	<body>
		
		<h1>
			Secure PubNub Publish ColdFusion Demo
		</h1>
		
		<h2>
			Messages:
		</h2>
		
		<ol class="messages">
			<!--- This will be populated dynamically. --->
		</ol>
		
		<!--- 
			Check to see if the user is logged-in. If not, they will 
			not be able to submit to the server. 
		--->
		<cfif session.user.isLoggedIn>
		
		
			<form class="message">
			
				<input type="hidden" name="uuid" value="#session.user.uuid#" />
				
				<input type="text" name="text" value="" size="40" />
				
				<button type="submit">
					Send Message
				</button>
				
			</form>
			
			<p>
				<a href="./logout.cfm">Log Out</a>.
			</p>
			
			
		<cfelse>
		
		
			<!--- 
				The user is not logged-in. Hide the form and only 
				show them a way to login. 
			--->
			<p>
				You must <a href="./login.cfm">Log In</a> in order 
				to post messages.
			</p>
			
			
		</cfif>
		
		<p>
			<em>
				<strong>Note:</strong> At the time of this writing,
				PubNub had some temporary debugging in place that 
				allowed a throttled number of publish requests to go
				through with "invalid" keys. This is for testing and
				is something they will be removing (or so I'm told). 
			</em>
		</p>
		
		
		<!--- --------------------------------------------- --->
		<!--- --------------------------------------------- --->
		
		
		<script type="text/javascript">
		
			// Cache DOM references.
			var dom = {};
			dom.messages = $( "ol.messages" );
			dom.form = $( "form.message" );
			dom.uuid = dom.form.find( "input[ name = 'uuid' ]" );
			dom.text = dom.form.find( "input[ name = 'text' ]" );
			
			
			// Override the form submission. Since the user cannot 
			// publish to the PubNub channel without a known PUB-KEY,
			// they will have to publish by-proxy, going through our
			// secure ColdFusion API.
			dom.form.submit(
				function( event ){
				
					// Prevent the default submit action.
					event.preventDefault();
					
					// Publish through the API.
					$.ajax({
						type: "post",
						url: "./publish.cfm",
						data: {
							uuid: dom.uuid.val(),
							text: dom.text.val()
						},
						dataType: "json",
						success: function(){
							
							// Clear the message text and re-focus
							// it for futher usage.
							dom.text
								.val( "" )
								.focus()
							;
							
						},
						error: function(){
							
							// The user is probably not logged-in.
							alert( "Something went wrong." );
							
						}
					});
					
				}
			);
			
			
			// I add the incoming messages to the UI.
			function appendMessage( message ){
			
				// Create a new list item.
				var messageItem = $( "<li />" )
					.attr( "data-uuid", message.uuid )
					.text( message.text )
				;
				
				// Add the message to the current list.
				dom.messages.append( messageItem );
			
			}
			
			
			// Subsribe to the appropriate PubNub channel for 
			// receiving messages in this secure application.
			PUBNUB.subscribe({
				channel: "coldfusion:secure_publish",
				callback: appendMessage
			});
		
		</script>
		
	</body>
	</html>

</cfoutput>