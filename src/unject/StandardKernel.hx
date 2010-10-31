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
	var scopes : Hash<Scope>;
	var singletons : Hash<Dynamic>;
	//var modules : Array<IUnjectModule>;
	var constructors : Hash<List<BindingArgument>>;
	var parameters : Hash<Hash<Dynamic>>;

	public function new(modules : Array<Dynamic>)
	{
		this.bindings = new Hash<ClassType>();
		this.scopes = new Hash<Scope>();
		this.singletons = new Hash<Dynamic>();
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
		/*
		var typeName = Type.getClassName(type);
		if (!bindings.exists(typeName))
			throw typeName + " has not been bound to any class.";
		*/
			
		return internalGet(type);
	}

	function internalGet<T>(type : Class<T>) : T 
	{
		var typeName = Type.getClassName(type);
		var binding = bindings.exists(typeName) ? bindings.get(typeName) : type;
		var scope = scopes.exists(typeName) ? scopes.get(typeName) : Scope.transient;
		
		var self = this;
		var instance = function()
		{
			if (!self.bindings.exists(typeName) && Type.resolveClass(typeName) == null)
				throw typeName + " is an unbound interface and cannot be instantiated.";

			try
			{
				return Type.createInstance(binding, self.resolveConstructorParameters(binding));
			}
			catch (e : Dynamic)
			{
				if(!URtti.hasInfo(binding))
					throw "Class " + typeName + " must implement haxe.rtti.Infos";
				else
				{
					#if neko
					return neko.Lib.rethrow(e);
					#elseif php
					return cast php.Lib.rethrow(e);
					#else
					throw e;
					#end
				}
			}
		};
		
		return switch(scope)
		{
			case transient:
				instance();
				
			case singleton:
				if (!singletons.exists(typeName))
					singletons.set(typeName, instance());
				
				singletons.get(typeName);
		}
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
			else if(a.type != null && !URtti.isValueType(a.type))
				return self.internalGet(a.type);
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
		//trace("Get constructor params for " + Type.getClassName(type));

		// If an interface has no infos, try to auto-resolve it by using a parameterless constructor.
		if (!URtti.hasInfo(type))
			return new List<BindingArgument>();

		var fields = URtti.getClassFields(type);
		
		if (!fields.exists("new"))
			throw "No constructor found on class " + Type.getClassName(type);
						
		var self = this;
		
		return Lambda.map(URtti.methodArguments(fields.get("new")), function(arg : RttiArgument) {
			switch(arg.t)
			{
				case CClass(name, params), CEnum(name, params):
					var resolved = Type.resolveClass(name);
					
					#if php
					// Haxe/PHP cannot resolve interfaces, so a workaround is needed.
					if (resolved == null)
						resolved = untyped __call__("_hx_qtype", name);
					#end
					
					//trace("Resolved type: " + name);
					return { type: resolved, name: arg.name };
					
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
	
	public function setScope(type : Class<Dynamic>, scope : Scope)
	{
		scopes.set(Type.getClassName(type), scope);
	}
}