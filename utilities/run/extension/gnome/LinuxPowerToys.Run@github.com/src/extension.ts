import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import { RunSummoning } from './summoning';

export default class MyExtension extends Extension {
    summoning: RunSummoning = new RunSummoning(this.getSettings());

    enable(): void {
        this.summoning.enable();
        console.log("linux power toys run gnome extension enabled");
    }

    disable(): void {
        this.summoning.disable();
        console.log("linux power toys run gnome extension disabled");
    }
}