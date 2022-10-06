/********************************************************************************************
* SIDH: an efficient supersingular isogeny cryptography library
*
* Abstract: benchmarking/testing isogeny-based key exchange SIDHp377
*********************************************************************************************/ 

#include <stdio.h>
#include <string.h>
#include "test_extras.h"
#include "../src/P377/P377_api.h"


#define SCHEME_NAME    "SIDHp377"

#define random_mod_order_A            random_mod_order_A_SIDHp377
#define random_mod_order_B            random_mod_order_B_SIDHp377
#define EphemeralKeyGeneration_A      EphemeralKeyGeneration_A_SIDHp377
#define EphemeralKeyGeneration_B      EphemeralKeyGeneration_B_SIDHp377
#define EphemeralSecretAgreement_A    EphemeralSecretAgreement_A_SIDHp377
#define EphemeralSecretAgreement_B    EphemeralSecretAgreement_B_SIDHp377

#include "test_sidh.c"