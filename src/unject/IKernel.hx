package unject;

/**
 * ...
 * @author Andreas Soderlund
 */

interface IKernel 
{
	function get<T>(type : Class<T>) : T;
	function bind(type : Class<Dynamic>, to : Class<Dynamic>) : Void;
}