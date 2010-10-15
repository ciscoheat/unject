package unject;

/**
 * ...
 * @author Andreas Soderlund
 */

interface IBindingToSyntax 
{
	function to(to : Class<Dynamic>) : Void; // : IBindingInSyntax;
	function toSelf() : Void; // : IBindingInSyntax;
}