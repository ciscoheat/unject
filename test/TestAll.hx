import utest.MacroRunner;
import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		unject.TestAll.addTests(runner);
	}
	
	public static function main()
	{
		#if neko
		runTests();
		#else
		try {
			var runner = new Runner();
			addTests(runner);
			Report.create(runner);
			runner.run();   
		} catch(e : Dynamic) {
			trace(e);
		}
		#end
	}
	
	@:macro static function runTests()
	{
		return MacroRunner.run(addTests);
	}
}