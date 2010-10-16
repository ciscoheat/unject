package unject;

/**
 * ...
 * @author Andreas Soderlund
 */
class UnjectModule implements IUnjectModule
{
	public var kernel : IKernel;
	
	public function new() {}
		
	public function load() { }
	
	public function bind(type : Class<Dynamic>) : IBindingToSyntax
	{
		return new BindTo(kernel, type);
	}	
}

class BindTo implements IBindingToSyntax, implements IBindingWithSyntax
{
	var kernel : IKernel;
	var type : Class<Dynamic>;
	
	public function new(kernel : IKernel, type : Class<Dynamic>)
	{
		this.kernel = kernel;
		this.type = type;
	}
	
	public function to(to : Class<Dynamic>)
	{
		kernel.bind(type, to);
		return cast this;
	}
	
	public function toSelf()
	{
		kernel.bind(type, type);
		return cast this;
	}
	
	public function withParameter(name : String, value : Dynamic)
	{
		kernel.setParameter(type, name, value);
		return cast this;
	}	
}