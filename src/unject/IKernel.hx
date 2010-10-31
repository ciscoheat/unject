package unject;

/**
 * ...
 * @author Andreas Soderlund
 */

interface IKernel 
{
	function get<T>(type : Class<T>) : T;
	function bind(type : Class<Dynamic>, to : Class<Dynamic>) : Void;
	function setParameter(type : Class<Dynamic>, name : String, value : Dynamic) : Void;
	function setScope(type : Class<Dynamic>, scope : Scope) : Void;
}