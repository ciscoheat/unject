package unject;

/**
 * ...
 * @author Andreas Soderlund
 */

interface IBindingToSyntax 
{
	function to(to : Class<Dynamic>) : IBindingWithInSyntax;
	function toSelf() : IBindingWithInSyntax;
}