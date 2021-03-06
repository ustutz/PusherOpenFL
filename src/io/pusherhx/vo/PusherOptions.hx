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

package io.pusherhx.vo;

/**
 * Pusher <http://pusher.com> Options Storage Object
 * @author Tilman Griesel <https://github.com/TilmanGriesel>
 */
class PusherOptions
{
	public var origin:Null<String>;
	public var applicationKey:Null<String>;

	public var version(default,null):String = '2.1';
	public var protocol:String = '5';
	public var secure:Bool = false;
	public var host:String = 'ws.pusherapp.com';
	public var wsPort:UInt = 80;
	public var wssPort:UInt = 443;
	public var authEndpoint:String = '/pusher/auth';
	public var autoPing:Bool;
	public var pingPongBasedDisconnect:Bool;
	public var pingInterval:Float = 750;
	public var pingPongTimeout:Float = 7500;
	public var interruptTimeout:Float = 1000;
	@var public var connectionPath(get, null):String;
	@var public var pusherURL(get, null):String;
	@var public var pusherSecureURL(get, null):String;
	
	public function new( applicationKey:Null<String> = null, origin:Null<String> = null )
	{ 
		this.applicationKey = applicationKey;
		this.origin = origin;
	}

	// Convenience Getters
	
	public function get_connectionPath():String {
		return	'/app/' + applicationKey + "?client=js&version=" + version + '&protocol=' + protocol;
	}

	public function get_pusherURL():String {
		return	'ws://' + host + ":" + wsPort + connectionPath;
	}
	
	public function get_pusherSecureURL():String {
		return	'wss://' + host + ":" + wssPort + connectionPath;
	}
}