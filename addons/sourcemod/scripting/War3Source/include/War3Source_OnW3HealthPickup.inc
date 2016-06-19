/**
 * File: War3Source_OnW3HealthPickup.inc
 * Author(s): El Diablo
 *
 */

/**
 * When player hits picks up health (item_healthkit_small, item_healthkit_medium, or item_healthkit_full)
 *
 * @param output
 * @param caller
 * @param activator - most likely client
 * @param delay
 *
 * @param return - no return
 *
 */
forward OnW3HealthPickup(const String:output[], caller, activator, Float:delay);
