// War3Source_stocks_precache.inc

#if GGAMETYPE == GGAME_CSGO
#define BEAMSPRITE_SOURCE "materials/sprites/laserbeam.vmt"
#define HALOSPRITE_SOURCE "materials/sprites/halo.vmt"
#else
#define BEAMSPRITE_SOURCE "materials/sprites/lgtning.vmt"
#define HALOSPRITE_SOURCE "materials/sprites/halo01.vmt"
#endif

// default beamsprite which is often used (moved here to keep compatibilty across diff. games)
stock War3_PrecacheBeamSprite() {

	int w3_spriteindex = PrecacheModel(BEAMSPRITE_SOURCE);

	if(w3_spriteindex == -1) {
		LogError("Failed to precache BeamSprite material!");
	}
	return w3_spriteindex;
}
// same goes for halosprite
stock War3_PrecacheHaloSprite() {
	int w3_spriteindex = PrecacheModel(HALOSPRITE_SOURCE);
	if(w3_spriteindex == -1) {
		LogError("Failed to precache HaloSprite material!");
	}
	return w3_spriteindex;
}
