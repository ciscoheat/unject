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
		Assert.raises(function() { k.get(NoInfos); }, String);
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
		
		Assert.raises(function() { k.get(Japan); }, String);
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
		Assert.raises(function() { k.get(Wakizachi); }, String);
	}
}

///// Test classes ////////////////////////////////

class TestModule extends UnjectModule
{
	public override function load()
	{
		bind(IWeapon).to(Sword);
		bind(IMagic).to(Fireball);
		
		bind(Ninja).toSelf();
		
		bind(Katana).toSelf()
			.withParameter("sharpness", 100)
			.withParameter("used", true);
	}
}

class NoInfos { }
class NoConstructor implements Infos { }

class Wakizachi implements Infos
{
	public function new(sharpness : Int) {}
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
	var magic : IMagic;
	
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
interface IShogun {}

class Japan implements Infos
{
	public function new(shogun : IShogun) {}
}

interface IWeapon
{
	function hit(target : String) : String;
}

interface IMagic
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
