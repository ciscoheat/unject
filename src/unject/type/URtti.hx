package unject.type;
        
import haxe.rtti.CType;

class URtti
{
	public static function isValueType(c : Dynamic)
	{
		if (!Std.is(c, Class))
		{			
			switch(Type.typeof(c))
			{
				case TClass(cls): c = cls;				
				default: return true;
			}
		}
		
		var name = Type.getClassName(cast c);
		return name == "Int" || name == "Float" || name == "String";
	}
	
	public static function typeName(type : CType, opt : Bool) : String 
	{
		switch(type) 
		{
			case CFunction(_,_):
				return opt ? "Null<function>" : "function";
			case CUnknown:
				return opt ? "Null<unknown>" : "unknown";
			case CAnonymous(_), CDynamic(_):
				return opt ? "Null<Dynamic>" : "Dynamic"; 
			case CTypedef(name, params):
				if(name == "Null")
				{                
					if(opt)
					{
						var t = name;
						if(params != null && params.length > 0) 
						{
							var types = [];
							for(p in params)
								types.push(typeName(p, false));
							t += '<'+types.join(',')+'>';
						}
						return t;
					} else {
						return typeName(params.first(), false);
					}
				} else {
					var t = name;
					if(params != null && params.length > 0)
					{
						var types = [];
						for(p in params)
							types.push(typeName(p, false));
						t += '<'+types.join(',')+'>';
					}
					return opt ? 'Null<'+t+'>' : t;	
				}
			case CEnum(name, params), CClass(name, params):
				var t = name;
				if(params != null && params.length > 0) 
				{
					var types = [];
					for(p in params)
						types.push(typeName(p, false));
					t += '<'+types.join(',')+'>';
				}
				return opt ? 'Null<'+t+'>' : t;
		}
	}       
	
	public static function methodArguments(field : ClassField)
	{
		switch(field.type)
		{
			case CFunction(args, _):
			    return args;
			default:
				return null;
		}
	}  
	
	public static function methodReturnType(field : ClassField)
	{
		switch(field.type)
		{
			case CFunction(_, ret):
				return ret;
			default:
				return null;
		}
	}
	
	public static function argumentAcceptNull(arg : {name : String, opt : Bool, t : CType})
	{
		if(arg.opt)
			return true;
		switch(arg.t)
		{
			case CTypedef(n, _):
				return "Null" == n;
			default:
				return false;
		}
	}
	
	public static function getClassFields(cls : Class<Dynamic>)
	{
		return unifyFields(getClassDef(cls));
	}

	public static function unifyFields(cls : Classdef, ?h : Hash<ClassField>) : Hash<ClassField> 
	{
		if(h == null) 
			h = new Hash();
		for(f in cls.fields)
			if(!h.exists(f.name))
				h.set(f.name, f);
		var parent = cls.superClass;
		if(parent != null) 
		{		
			var pcls = Type.resolveClass(parent.path);
			
			#if !cpp
			var rtti = untyped pcls.__rtti;
			#else
			var rtti = Reflect.field(pcls, "__rtti");
			#end

			var x = Xml.parse(rtti).firstElement();
			switch(new haxe.rtti.XmlParser().processElement(x)) 
			{
				case TClassdecl(c):
			   		unifyFields(c, h);
				default:
					throw "Invalid type parent type (" + parent.path + ") for class: " + cls;
			}
		}
		return h;
	}
    
	public static function hasInfo(cls : Class<Dynamic>) : Bool
	{
		#if !cpp
		return null != untyped cls.__rtti;
		#else
		return Reflect.hasField(cls, "__rtti");
		#end
	}

	public static function getClassDef(cls : Class<Dynamic>)
	{
		#if !cpp
		var rtti = untyped cls.__rtti;
		#else
		var rtti = Reflect.field(cls, "__rtti");
		#end
		
		var x = Xml.parse(rtti).firstElement();
		var infos = new haxe.rtti.XmlParser().processElement(x);

		var cd;
		switch(infos) 
		{
			case TClassdecl(c): 
				cd = c;
			default: 
				throw "Not a class!";
		}
		return cd;
	}
	
	public static function isMethod(field : ClassField) 
	{
		return switch(field.type)
		{
			case CFunction(_, _): true; 
			default: false;
		}
	}
}