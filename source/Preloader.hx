package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import sys.thread.Thread;

typedef Asset = {
    var name:String;
    var library:String;
    var compress:Bool;
}

class Preloader {

    public static var donePreload:Array<Bool> = [];
    public static function initialize(workload:String, preloadGroup:FlxSpriteGroup) {
        donePreload = [];
        
        var threadLimit:Int = Std.parseInt(Sys.getEnv("NUMBER_OF_PROCESSORS"));
        trace(threadLimit + ' amount of cores');
    
        var threadBacklog:Array<Array<Asset>> = [];
        for (i in 0...threadLimit) {
            donePreload[i] = false;
            threadBacklog[i] = [];
        }

        // set up the divided workflows
        var establishedWorkload:Array<Asset> = getWorkload(workload);
        var counter:Int = 0;
        for (i in establishedWorkload) {
            threadBacklog[counter].push(i);
            counter++;
            if (counter >= threadLimit)
                counter = 0;
        }

        for (i in 0...threadLimit) {
            var currentTime = Sys.time();
            Thread.create(function(){
                while (threadBacklog[i].length > 0) {
                    var storedGraphic = Paths.returnGraphic(threadBacklog[i][0].name, threadBacklog[i][0].library, threadBacklog[i][0].compress);
                    preloadGroup.add(new FlxSprite().loadGraphic(storedGraphic));
                    threadBacklog[i].splice(0, 1);
                }
                donePreload[i] = true;

                var finishedTime = Sys.time();
			    return trace('thread $i took ' + (finishedTime - currentTime) + " seconds.");
            });
        }

        // pause the game until the threads are all done
        while (donePreload.contains(false)) {}
    }

    static function getWorkload(workload:String):Array<Asset> {
        var finalWorkload:Array<Asset> = [];
        switch (workload) {
            case 'too-slow':

            case 'triple-trouble':

            case 'you-cant-run':

            default:
        }

        finalWorkload.push({name: 'STATIC', library: 'exe', compress: false});
        
        finalWorkload.push({name: 'sick', library: 'shared', compress: false});
        finalWorkload.push({name: 'good', library: 'shared', compress: false});
        finalWorkload.push({name: 'bad', library: 'shared', compress: false});
        finalWorkload.push({name: 'shit', library: 'shared', compress: false});

        for (number in 0...9)
            finalWorkload.push({name: 'num$number', library: '', compress: false});

        return finalWorkload;
    }
}