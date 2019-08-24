#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <sdktools>
#include <tf_ontakedamage>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION 		"1.0.0"

public Plugin myinfo =
{
	name = "[TF2] Mini-Crit Projectiles",
	author = "Scag",
	description = "Projectiles remember their mini status",
	version = PLUGIN_VERSION,
	url = ""
};

bool
	bMiniStatus[1 << 11]
;

public void OnEntityCreated(int ent, const char[] classname)
{
	if (!StrContains(classname, "tf_projectile", false))
		SDKHook(ent, SDKHook_SpawnPost, OnProjSpawn);
}

public void OnProjSpawn(int ent)
{
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (!(0 < owner <= MaxClients))
		return;

	if (GetEntProp(ent, Prop_Send, "m_bCritical"))
		return;

	bMiniStatus[ent] = TF2_IsPlayerInCondition(owner, TFCond_CritCola)
					|| TF2_IsPlayerInCondition(owner, TFCond_Buffed)
					|| TF2_IsPlayerInCondition(owner, TFCond_CritHype);
}

public Action TF2_OnTakeDamage(int victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &crittype)
{
	if (weapon == -1)	// Fuck
		return Plugin_Continue;

	if (inflictor != -1 && bMiniStatus[inflictor] && crittype < CritType_MiniCrit)
	{
		crittype = CritType_MiniCrit;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}