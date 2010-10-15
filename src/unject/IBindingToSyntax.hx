package unject;

/**
 * ...
 * @author Andreas Soderlund
 */

interface IBindingToSyntax 
{
	function to(to : Class<Dynamic>) : Void; // : IBindingWithSyntax;
	function toSelf() : Void; // : IBindingWithSyntax;
}