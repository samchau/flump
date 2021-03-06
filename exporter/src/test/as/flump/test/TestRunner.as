//
// Flump - Copyright 2012 Three Rings Design

package flump.test {

import flash.desktop.NativeApplication;
import flash.filesystem.File;

import executor.Executor;
import executor.Future;
import executor.VisibleFuture;

import starling.display.Sprite;

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

public class TestRunner extends Sprite
{
    public static const root :File = new File(File.applicationDirectory.nativePath);
    public static const resources :File = root.resolvePath('../src/test/resources');
    public static const dist :File = root.resolvePath('../dist');

    public function TestRunner () {
        Log.setLevel("", Log.INFO);
        _exec.completed.add(onCompletion);
        _exec.terminated.add(function (..._) :void {
            if (_passed.length > 0) {
                trace("Passed:");
                for each (var name :String in _passed) trace("  " + name);
            }
            if (_failed.length > 0) {
                trace("Failed:");
                for each (name in _failed) trace("  " + name);
            }
            NativeApplication.nativeApplication.exit(_failed.length == 0 ? 0 : 1);
        });
        new XflParseTest(this);
    }

    public function run (name :String, f :Function) :void {
        runAsync(name, function (future :VisibleFuture) :void { future.succeedAfter(f); });
    }

    public function runAsync (name :String, f :Function) :void { _runs.put(_exec.submit(f), name); }

    protected function onCompletion (f :Future) :void {
        const name :String = _runs.remove(f);
        if (name == null) {
            log.error("Unknown test completed", "future", f, "result", f.result);
            return;
        }
        if (f.isSuccessful) {
            log.info("Passed", "test", name);
            _passed.push(name);
        } else {
            _failed.push(name)
            if (f.result is Error) log.error("Failed", "test", name, f.result);
            else log.error("Failed", "test", name, "reason", f.result);
            _exec.shutdownNow();
        }
        if (_exec.isIdle) _exec.shutdown();
    }

    protected const _exec :Executor = new Executor();
    protected const _runs :Map = Maps.newMapOf(Future);//String name

    protected const _passed :Vector.<String> = new <String>[];
    protected const _failed :Vector.<String> = new <String>[];

    private static const log :Log = Log.getLog(TestRunner);
}
}
