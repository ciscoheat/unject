package unject;

/**
 * ...
 * @author Andreas Soderlund
 */

interface IUnjectModule 
{
	var kernel : IKernel;
	
	function load() : Void;
}