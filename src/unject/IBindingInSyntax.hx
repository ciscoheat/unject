package unject;

/**
 * ...
 * @author Andreas Soderlund
 */

interface IBindingInSyntax 
{
	/// <summary>
	/// Indicates that only a single instance of the binding should be created, and then
	/// should be re-used for all subsequent requests.
	/// </summary>
	function inSingletonScope();

	/// <summary>
	/// Indicates that instances activated via the binding should not be re-used, nor have
	/// their lifecycle managed by unject. (Default)
	/// </summary>
	function inTransientScope();

	/// <summary>
	/// Indicates that instances activated via the binding should be re-used within the same thread.
	/// </summary>
	function inThreadScope();

	/// <summary>
	/// Indicates that instances activated via the binding should be re-used within the same
	/// HTTP request.
	/// </summary>
	function inRequestScope();
}