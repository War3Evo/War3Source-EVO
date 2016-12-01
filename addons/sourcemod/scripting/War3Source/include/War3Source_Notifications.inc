/**
 * File: War3Source_Notifications.inc
 * Description: Easier stocks for notification
 * Author(s): War3Source Team
 */

/**
 * Show somebody that an enemy skill caused them damage
 */
native War3_NotifyPlayerTookDamageFromSkill(victim, attacker, damage, skill);

#if GGAMEMODE == MODE_WAR3SOURCE
native War3_NotifyPlayerTookDamageFromItem(victim, attacker, damage, item);
#endif

native War3_NotifyPlayerLeechedFromSkill(victim, attacker, health, skill);

#if GGAMEMODE == MODE_WAR3SOURCE
native War3_NotifyPlayerLeechedFromItem(victim, attacker, health, item);
#endif

native War3_NotifyPlayerImmuneFromSkill(attacker, victim, skill);

#if GGAMEMODE == MODE_WAR3SOURCE
native War3_NotifyPlayerImmuneFromItem(attacker, victim, skill);
#endif

native War3_NotifyPlayerSkillActivated(client,skill,bool:activated);

#if GGAMEMODE == MODE_WAR3SOURCE
native War3_NotifyPlayerItemActivated(client,item,bool:activated);
#endif
