/*
 * RELIC is an Efficient LIbrary for Cryptography
 * Copyright (c) 2019 RELIC Authors
 *
 * This file is part of RELIC. RELIC is legal property of its developers,
 * whose names are not listed here. Please refer to the COPYRIGHT file
 * for contact information.
 *
 * RELIC is free software; you can redistribute it and/or modify it under the
 * terms of the version 2.1 (or later) of the GNU Lesser General Public License
 * as published by the Free Software Foundation; or version 2.0 of the Apache
 * License as published by the Apache Software Foundation. See the LICENSE files
 * for more details.
 *
 * RELIC is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the LICENSE files for more details.
 *
 * You should have received a copy of the GNU Lesser General Public or the
 * Apache License along with RELIC. If not, see <https://www.gnu.org/licenses/>
 * or <https://www.apache.org/licenses/>.
 */

/**
 * @file
 *
 * Implementation of multiplication in a quartic extension of a prime field.
 *
 * @ingroup fpx
 */

#include "relic_core.h"
#include "relic_fp_low.h"
#include "relic_fpx_low.h"

/*============================================================================*/
/* Public definitions                                                         */
/*============================================================================*/

#if FPX_RDC == BASIC || !defined(STRIP)

void fp4_mul_basic(fp4_t c, const fp4_t a, const fp4_t b) {
	fp2_t t0, t1, t2;

	fp2_null(t0);
	fp2_null(t1);
	fp2_null(t2);

	RLC_TRY {
		fp2_new(t0);
		fp2_new(t1);
		fp2_new(t2);

		/* Karatsuba algorithm. */

		/* t0 = a_0 * b_0. */
		fp2_mul(t0, a[0], b[0]);
		/* t1 = a_1 * b_1. */
		fp2_mul(t1, a[1], b[1]);
		/* t2 = b_0 + b_1. */
		fp2_add(t2, b[0], b[1]);

		/* c_1 = a_0 + a_1. */
		fp2_add(c[1], a[0], a[1]);

		/* c_1 = (a_0 + a_1) * (b_0 + b_1) */
		fp2_mul(c[1], c[1], t2);
		fp2_sub(c[1], c[1], t0);
		fp2_sub(c[1], c[1], t1);

		/* c_0 = a_0b_0 + v * a_1b_1. */
		fp2_mul_nor(t2, t1);
		fp2_add(c[0], t0, t2);
	} RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY {
		fp2_free(t0);
		fp2_free(t1);
		fp2_free(t2);
	}
}

#endif

#if PP_EXT == LAZYR || !defined(STRIP)

void fp4_mul_unr(dv4_t c, const fp4_t a, const fp4_t b) {
	fp2_t t0, t1;
	dv2_t u0, u1;

	fp2_null(t0);
	fp2_null(t1);
	dv2_null(u0);
	dv2_null(u1);

	RLC_TRY {
		fp2_new(t0);
		fp2_new(t1);
		dv2_new(u0);
		dv2_new(u1);

#ifdef RLC_FP_ROOM
		fp2_mulc_low(u0, a[0], b[0]);
		fp2_mulc_low(u1, a[1], b[1]);
		fp2_addn_low(t0, b[0], b[1]);
		fp2_addn_low(t1, a[0], a[1]);
#else
		fp2_muln_low(u0, a[0], b[0]);
		fp2_muln_low(u1, a[1], b[1]);
		fp2_addm_low(t0, b[0], b[1]);
		fp2_addm_low(t1, a[0], a[1]);
#endif
		fp2_muln_low(c[1], t1, t0);
		fp2_subc_low(c[1], c[1], u0);
		fp2_subc_low(c[1], c[1], u1);
#ifdef RLC_FP_ROOM
		fp2_norh_low(c[0], u1);
#else
		fp2_nord_low(c[0], u1);
#endif
		fp2_addc_low(c[0], c[0], u0);
	} RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY {
		fp2_free(t0);
		dv2_free(t1);
		dv2_free(u0);
		dv2_free(u1);
	}
}

/////////////////////////////////////////////////////// Implementation with full new arithmetic for fp4_mul
void precomp509(dig_t* c, const dig_t* a)
{ // Precomputes (b10+b11), (b10-b11) 
	precomp509_asm(&c[0 * 8], &a[2 * 8]);
}

void fp4_mul_lazyr(fp4_t c, const fp4_t a, const fp4_t b) {
	fp_t t[6];

	fp_null(t[0]);
	fp_null(t[1]);
	fp_null(t[2]);
	fp_null(t[3]);
	fp_null(t[4]);
	fp_null(t[5]);

	RLC_TRY{
		fp_new(t[0]);
		fp_new(t[1]);
		fp_new(t[2]);
		fp_new(t[3]);
		fp_new(t[4]);
		fp_new(t[5]);

		precomp509((dig_t*)t[4], (dig_t*)b);  // Stores (b10+b11), (b10-b11)     
		fp4mul509c0_asm(t[0], a, b);
		fp4mul509c1_asm(t[0], a, b);
		fp4mul509c2_asm(t[0], a, b);
		fp4mul509c3_asm(t[0], a, b);
		fp4_copy(c, (dig_t*)t[0]);

	} RLC_CATCH_ANY{
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY{
		fp_free(t[0]);
		fp_free(t[1]);
		fp_free(t[2]);
		fp_free(t[3]);
		fp_free(t[4]);
		fp_free(t[5]);
	}
}

#endif

void fp4_mul_art(fp4_t c, const fp4_t a) {
	fp2_t t0;

	fp2_null(t0);

	RLC_TRY {
		fp2_new(t0);

		/* (a_0 + a_1 * v) * v = a_0 * v + a_1 * v^2 */
		fp2_copy(t0, a[0]);
		fp2_mul_nor(c[0], a[1]);
		fp2_copy(c[1], t0);
	} RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY {
		fp2_free(t0);
	}
}

void fp4_mul_frb(fp4_t c, const fp4_t a, int i, int j) {
	fp2_t t;

	fp2_null(t);

	RLC_TRY {
		fp2_new(t);

		fp_copy(t[0], core_get()->fp4_p1[0]);
		fp_copy(t[1], core_get()->fp4_p1[1]);

	    if (i == 1) {
			for (int k = 0; k < j; k++) {
	        	fp2_mul(c[0], a[0], t);
				fp2_mul(c[1], a[1], t);
				/* If constant in base field, then second component is zero. */
				if (core_get()->frb4 == 1) {
					fp4_mul_art(c, c);
				}
			}
	    } else {
			RLC_THROW(ERR_NO_VALID);
		}
	} RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY {
		fp2_free(t);
	}
}
