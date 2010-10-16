package unject;

/**
 * ...
 * @author Andreas Soderlund
 */

interface IBindingToSyntax 
{
	function to(to : Class<Dynamic>) : IBindingWithSyntax;
	function toSelf() : IBindingWithSyntax;
}