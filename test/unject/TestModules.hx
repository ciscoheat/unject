package unject;

import haxe.rtti.Infos;
import unject.type.URtti;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class TestModules
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new TestModules());
	}
	
	public static function main()
	{
		var runner = new Runner();
		addTests(runner);
		Report.create(runner);
		runner.run();
	}
	
	var kernel : IKernel;
	
	public function new();
	
	public function setup()
	{
		kernel = new StandardKernel([new TestModule()]);
	}
	
	public function testModuleLoad()
	{
		var samurai = kernel.get(Samurai);
		
		Assert.equals("Chopped the evildoers in half.", samurai.attack("the evildoers"));
	}

	public function testNoInfos()
	{
		var k = this.kernel;		
		k.bind(NoInfos, NoInfos);
		
		// Neko is behaving best and won't accept a class without a constructor.
		#if neko
		Assert.raises(function() { trace(k.get(NoInfos)); }, String);
		#else
		Assert.isTrue(Std.is(k.get(NoInfos), NoInfos));
		#end
	}
	
	public function testNoConstructor()
	{
		var k = this.kernel;
		
		k.bind(NoConstructor, NoConstructor);
		Assert.raises(function() { k.get(NoConstructor); }, String);
	}
	
	public function testNoMappingNoConstructor()
	{
		var kernel = this.kernel;
		
		Assert.equals("Chopped all enemies in half.", kernel.get(Sword).hit("all enemies"));
	}
	
	public function testNoMappingInConstructor()
	{
		var k = this.kernel;
		
		#if !js
		Assert.raises(function() { k.get(Japan); }, String);
		#else
		// Javascript manages to resolve this because of its default values.
		Assert.isTrue(Std.is(k.get(Japan), Japan));
		Assert.isTrue(Std.is(k.get(Japan).shogun, IShogun));
		#end
	}
	
	public function testMappingToSelf()
	{
		var ninja = kernel.get(Ninja);
		
		Assert.equals("Throws a fireball into the air.", ninja.doMagic());
		Assert.equals("Chopped the ronin in half. (Sneaky)", ninja.sneakAttack("the ronin"));
	}
	
	public function testWithParameter()
	{
		var katana = kernel.get(Katana);
		Assert.equals(100, katana.sharpness);
		Assert.equals(true, katana.used);
	}
	
	public function testWithUnBoundParameter()
	{
		var k = this.kernel;
		Assert.raises(function() { trace(k.get(Wakizachi).sharpness); }, String);
	}

	public function testGetInterface()
	{
		// This also tests autobinding since Fireball has a parameterless constructor.
		var magic = kernel.get(IMagic);
		Assert.isTrue(Std.is(magic, Fireball));
	}
	
	public function testSingletonScope()
	{
		var n1 = kernel.get(Ninja);
		var n2 = kernel.get(Ninja);

		Assert.notEquals(n1, n2);
		Assert.equals(n1.magic, n2.magic);
	}
	
	public function testAutoBindingFailing()
	{
		var k = this.kernel;		
		k.bind(IWeapon, MagicSword);
		
		// Flash and js manages to resolve this because of their default value handling.
		// Other platforms will complain on not enough constructor parameters.
		#if (js || flash)
		Assert.is(k.get(IWeapon), MagicSword);
		Assert.is(k.get(MagicSword), MagicSword);
		#else
		Assert.raises(function() { k.get(IWeapon); }, String);
		Assert.raises(function() { k.get(MagicSword); }, String);
		#end
	}	
}

///// Test classes ////////////////////////////////

class TestModule extends UnjectModule
{
	public override function load()
	{
		bind(IWeapon).to(Sword);
		
		bind(IMagic).to(Fireball).inSingletonScope();
		
		bind(Ninja).toSelf();
		bind(Samurai).toSelf();
		bind(Sword).toSelf();
		
		bind(Katana).toSelf()
			.withParameter("sharpness", 100)
			.withParameter("used", true);
	}
}

class NoInfos { }
class NoConstructor implements Infos { }

class Wakizachi implements Infos
{
	public var sharpness(default, null) : Int;
	
	public function new(sharpness : Int)
	{
		this.sharpness = sharpness;
	}
}

class Katana implements Infos
{
	public var sharpness : Int;
	public var used : Bool;
	
	public function new(sharpness : Int, used : Bool)
	{
		this.sharpness = sharpness;
		this.used = used;
	}
}

class Ninja implements Infos
{
	var weapon : IWeapon;
	public var magic : IMagic;
	
	public function new(weapon : IWeapon, magic : IMagic)
	{
		this.weapon = weapon;
		this.magic = magic;
	}
	
	public function sneakAttack(target : String)
	{
		return weapon.hit(target) + " (Sneaky)";
	}
	
	public function doMagic()
	{
		return magic.castSpell();
	}
}

class Samurai implements Infos
{
	var weapon : IWeapon;
	
	public function new(weapon : IWeapon)
	{
		this.weapon = weapon;
	}
	
	public function attack(target : String)
	{
		return weapon.hit(target);
	}
}

// Should not be mapped
interface IShogun
{
	public function rule() : Void;
}

class Japan implements Infos
{
	public var shogun(default, null) : IShogun;
	
	public function new(shogun : IShogun)
	{
		this.shogun = shogun;
	}
}

interface IWeapon
{
	function hit(target : String) : String;
}

interface IMagic implements Infos
{
	function castSpell() : String;
}

class Fireball implements IMagic, implements Infos
{
	public function new();
	
	public function castSpell()
	{
		return "Throws a fireball into the air.";
	}	
}

class Sword implements IWeapon, implements Infos
{
	public function new();
	
	public function hit(target : String)
	{
		return "Chopped " + target + " in half.";
	}
}

class MagicSword implements IWeapon
{
	public function new(boundSpell : IMagic);
	
	public function hit(target : String)
	{
		return "Chopped " + target + " in half.";
	}
}
