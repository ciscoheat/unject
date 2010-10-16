package unject;
import haxe.rtti.CType;
import unject.type.URtti;

/**
 * ...
 * @author Andreas Soderlund
 */

typedef RttiArgument = {
	var t : CType;
	var opt : Bool;
	var name : String;
}

typedef BindingArgument = {
	var type : ClassType;
	var name : String;
}

typedef ClassType = Class<Dynamic>;

class StandardKernel implements IKernel
{
	var bindings : Hash<ClassType>;
	//var modules : Array<IUnjectModule>;
	var constructors : Hash<List<BindingArgument>>;
	var parameters : Hash<Hash<Dynamic>>;

	public function new(modules : Array<Dynamic>)
	{
		this.bindings = new Hash<ClassType>();
		//this.modules = new Array<IUnjectModule>();
		this.constructors = new Hash<List<BindingArgument>>();
		this.parameters = new Hash<Hash<Dynamic>>();

		for (m in modules)
		{
			if (!Std.is(m, IUnjectModule))
				throw "Module must be a IUnjectModule.";

			var module = cast(m, IUnjectModule);
			
			#if !cpp
			module.kernel = this;
			#else
			Reflect.setField(module, "kernel", this);
			#end
			
			module.load();
			
			//this.modules.push(module);
		}
	}
	
	public function get<T>(type : Class<T>) : T 
	{
		return Type.createInstance(type, resolveConstructorParameters(type));
	}
	
	function resolveConstructorParameters(type : Class<Dynamic>) : Array<Dynamic>
	{
		var typeName = Type.getClassName(type);
		
		if (!constructors.exists(typeName))
			constructors.set(typeName, getConstructorParams(type));

		var params = constructors.get(typeName);		
		if (params.length == 0) return [];

		var self = this;
		return Lambda.array(Lambda.map(params, function(a : BindingArgument)
		{
			if (self.hasParameter(typeName, a.name))
				return self.getParameter(typeName, a.name);
			else if(a.type != null)
				return Type.createInstance(a.type, self.resolveConstructorParameters(a.type));
			else
				throw "No binding found for parameter '" + a.name + "' on class " + typeName;
		}));
	}
	
	function getParameter(typeName : String, parameterName : String)
	{
		return parameters.get(typeName).get(parameterName);
	}
	
	function hasParameter(typeName : String, parameterName : String)
	{
		return parameters.exists(typeName) && parameters.get(typeName).exists(parameterName);
	}
	
	function getConstructorParams(type : Class<Dynamic>) : List<BindingArgument>
	{
		if (!URtti.hasInfo(type))
			throw "Class " + Type.getClassName(type) + " must implement haxe.rtti.Infos";

		var fields = URtti.getClassFields(type);
		
		if (!fields.exists("new"))
			throw "No constructor found on class " + Type.getClassName(type);
			
		var self = this;
		
		return Lambda.map(URtti.methodArguments(fields.get("new")), function(arg : RttiArgument) {
			switch(arg.t)
			{
				case CClass(name, params), CEnum(name, params):
					return {type: self.bindings.get(name), name: arg.name}
					
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
	
	public function setParameter(type : Class<Dynamic>, name : String, value : Dynamic)
	{
		var typeName = Type.getClassName(type);
		
		if (!parameters.exists(typeName))
			parameters.set(typeName, new Hash<Dynamic>());
		
		//trace("Parameter " + name + " for " + typeName + " set to " + value);			
		parameters.get(typeName).set(name, value);
	}
}