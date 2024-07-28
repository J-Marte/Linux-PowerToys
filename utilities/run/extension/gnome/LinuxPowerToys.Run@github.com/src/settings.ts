import Gio from 'gi://Gio';

export const SUMMONING_KEY_NAME = "summon-keybinding"

export function get_summon_key_name(settings: Gio.Settings): string {
    return settings?.get_strv(SUMMONING_KEY_NAME)[0] ?? '';
}

export function set_summon_key_name(settings: Gio.Settings | undefined, value: string): boolean {
    return settings?.set_strv(SUMMONING_KEY_NAME, [value]) ?? false;
}
