package unject;

import haxe.rtti.Infos;
import unject.type.URtti;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class TestIsValueType
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new TestIsValueType());
	}
	
	public static function main()
	{
		var runner = new Runner();
		addTests(runner);
		Report.create(runner);
		runner.run();
	}
	
	public function new();
	
	public function testIsValueType()
	{
		Assert.isFalse(URtti.isValueType(TestIsValueType));
		Assert.isFalse(URtti.isValueType(Date));
		
		Assert.isTrue(URtti.isValueType(Int));
		Assert.isTrue(URtti.isValueType(Float));
		Assert.isTrue(URtti.isValueType(String));		
		Assert.isTrue(URtti.isValueType(Bool));
		
		Assert.isFalse(URtti.isValueType(new TestIsValueType()));
		
		Assert.isTrue(URtti.isValueType("abc"));
		Assert.isTrue(URtti.isValueType(123));
		Assert.isTrue(URtti.isValueType(123.45));
		Assert.isTrue(URtti.isValueType(true));
	}
}
