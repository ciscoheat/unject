package unject;
import haxe.rtti.CType;
import unject.type.URtti;

/**
 * ...
 * @author Andreas Soderlund
 */

typedef MethodArgument = {
	var t : CType;
	var opt : Bool;
	var name : String;
}
 
class StandardKernel implements IKernel
{
	var bindings : Hash<Class<Dynamic>>;
	//var modules : Array<IUnjectModule>;
	var constructors : Hash<List<Class<Dynamic>>>;

	public function new(modules : Array<Dynamic>)
	{
		this.bindings = new Hash<Class<Dynamic>>();
		//this.modules = new Array<IUnjectModule>();
		this.constructors = new Hash<List<Class<Dynamic>>>();

		for (m in modules)
		{
			if (!Std.is(m, IUnjectModule))
				throw "Module must be a IUnjectModule.";

			var module = cast(m, IUnjectModule);
			
			module.kernel = this;
			module.load();
			
			//this.modules.push(module);
		}
	}
	
	public function get<T>(type : Class<T>) : T 
	{
		return Type.createInstance(type, parameters(type));
	}
	
	function parameters(type : Class<Dynamic>) : Array<Dynamic>
	{
		var typeName = Type.getClassName(type);
		
		if (!constructors.exists(typeName))
			constructors.set(typeName, getConstructorParams(type));

		var params = constructors.get(typeName);			
		if (params.length == 0) return [];
		
		var self = this;
		return Lambda.array(Lambda.map(params, function(c : Class<Dynamic>) {
			return Type.createInstance(c, self.parameters(c));
		}));
	}
	
	function getConstructorParams(type : Class<Dynamic>) : List<Class<Dynamic>>
	{
		if (!URtti.hasInfo(type))
			throw "Class " + Type.getClassName(type) + " must implement haxe.rtti.Infos";

		var fields = URtti.getClassFields(type);
		
		if (!fields.exists("new"))
			throw "No constructor found on class " + Type.getClassName(type);
			
		var self = this;
		
		return Lambda.map(URtti.methodArguments(fields.get("new")), function(arg : MethodArgument) {
			switch(arg.t)
			{
				case CClass(name, params):
					return self.bindings.exists(name)
						? self.bindings.get(name)
						: throw "Could not find mapping for class " + name;
					
				default:
					throw "Parameter type not supported: " + arg.t;
			}
		});
	}
	
	public function bind(type : Class<Dynamic>, to : Class<Dynamic>)
	{
		var typeName = Type.getClassName(type);
		
		bindings.set(typeName, to);
	}
}