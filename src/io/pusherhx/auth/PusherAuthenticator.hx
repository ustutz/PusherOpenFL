// The MIT License (MIT)
//
// Copyright (c) 2014 Tilman Griesel - <http://rocketengine.io> <http://github.com/TilmanGriesel>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//		
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

package io.pusherhx.auth;

import haxe.Json;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IEventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;

import io.pusherhx.events.PusherAuthenticationEvent;

class PusherAuthenticator extends EventDispatcher {
	
	public function new() {
		super();
	}
	
	public function authenticate(socketID:String, endPoint:String, channelName:String):Void	{
		
		trace('authenticate socket connection (socketID:' + socketID + ',endpoint:' + endPoint + ',channelName:' + channelName + ')...');
		
		var urlLoader:URLLoader = new URLLoader();
		var urlRequest:URLRequest = new URLRequest(endPoint);
		var postVars:URLVariables = new URLVariables();
		postVars.socketId = socketID;
		postVars.channel_name = channelName;
		
		urlRequest.data = postVars;	
		urlRequest.method = URLRequestMethod.POST;
		
		configureListeners(urlLoader);
		
		try {
			urlLoader.load(urlRequest);
		} catch (error:Error) {
			trace('unable to load authentication request! (' + error.message + ')');
		}
	}
	
	function configureListeners(dispatcher:IEventDispatcher):Void {
		
		dispatcher.addEventListener(Event.COMPLETE, urlLoader_COMPLETE);
		dispatcher.addEventListener(Event.OPEN, urlLoader_OPEN);
		dispatcher.addEventListener(ProgressEvent.PROGRESS, urlLoader_PROGRESS);
		dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoader_SECURITY_ERROR);
		dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, urlLoader_HTTP_STATUS);
		dispatcher.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_IO_ERROR);
	}
	
	function urlLoader_COMPLETE(event:Event):Void {
		
		var loader = event.target;
		
		if (loader.hasOwnProperty('data') == true) {
			
			var decodedData:Dynamic = Json.parse(loader.data);
			
			if(decodedData.hasOwnProperty('auth')) {
				
				var authString:String = decodedData.auth;
				trace('authentication successful (auth: ' + authString + ')');
				this.dispatchEvent(new PusherAuthenticationEvent(PusherAuthenticationEvent.SUCCESSFUL, authString));	
			
			} else {
				
				trace('authentication failed! Property "auth" not found in response data!');
				this.dispatchEvent(new PusherAuthenticationEvent(PusherAuthenticationEvent.FAILED));
			}
		} else {
			
			trace('authentication failed! Property "data" not found in response data!');
			this.dispatchEvent(new PusherAuthenticationEvent(PusherAuthenticationEvent.FAILED));	
		}
			
		loader.close();
	}
	
	function urlLoader_OPEN(event:Event):Void {
		// empty
	}
	
	function urlLoader_HTTP_STATUS(event:HTTPStatusEvent):Void {
		// empty
	}
	
	function urlLoader_PROGRESS(event:ProgressEvent):Void {
		// empty
	}
	
	function urlLoader_SECURITY_ERROR(event:SecurityErrorEvent):Void {
		trace('security error! (' + event + ')');
		
		this.dispatchEvent(new PusherAuthenticationEvent(PusherAuthenticationEvent.FAILED));
		
		// close connection
		var loader = event.target;
		loader.close();
	}
	
	function urlLoader_IO_ERROR(event:IOErrorEvent):Void {
		trace('io error! (' + event + ')');
		
		this.dispatchEvent(new PusherAuthenticationEvent(PusherAuthenticationEvent.FAILED));
		
		// close connection
		var loader = event.target;
		loader.close();
	}
}
