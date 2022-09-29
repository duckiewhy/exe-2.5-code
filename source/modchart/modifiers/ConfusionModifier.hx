package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.*;

class ConfusionModifier extends Modifier {
  override function updateNote(note:Note, player:Int, pos:Vector3, scale:FlxPoint){
    var player = note.mustPress==true?0:1;
    if(!note.isSustainNote)
      note.angle = (getPercent(player) + getSubmodPercent('confusion${note.noteData}',player) + getSubmodPercent('note${note.noteData}Angle',player))*100;
    

  }

  override function updateReceptor(receptor:StrumNote, player:Int, pos:Vector3, scale:FlxPoint){
    receptor.angle = (getPercent(player) + getSubmodPercent('confusion${receptor.noteData}',player) + getSubmodPercent('receptor${receptor.noteData}Angle',player))*100;
  }

  override function getSubmods(){
    var subMods:Array<String> = ["noteAngle","receptorAngle"];

    var receptors = modMgr.receptors[0];
    var kNum = receptors.length;
    for(recep in receptors){
      subMods.push('note${recep.noteData}Angle');
      subMods.push('receptor${recep.noteData}Angle');
      subMods.push('confusion${recep.noteData}');
    }

    return subMods;
  }
}
