import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import { RunSummoning } from './summoning';
import { WindowPositioner } from './positioning';

export default class MyExtension extends Extension {
    summoning: RunSummoning = new RunSummoning(this.getSettings());
    positioner: WindowPositioner = new WindowPositioner();

    enable(): void {
        this.summoning.enable();
        this.positioner.enable();
        console.log("linux power toys run gnome extension enabled");
    }

    disable(): void {
        this.summoning.disable();
        this.positioner.disable();
        console.log("linux power toys run gnome extension disabled");
    }
}