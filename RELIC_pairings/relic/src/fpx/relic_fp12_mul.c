/*
 * RELIC is an Efficient LIbrary for Cryptography
 * Copyright (c) 2012 RELIC Authors
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
 * Implementation of multiplication in a dodecic extension of a prime field.
 *
 * @ingroup fpx
 */

#include "relic_core.h"
#include "relic_fp_low.h"
#include "relic_fpx_low.h"

/*============================================================================*/
/* Private definitions                                                        */
/*============================================================================*/

#if FPX_RDC == LAZYR || !defined(STRIP)

/////////////////////////////////////////////////////// Copy of basic fp6_mul_dxs version
inline static void fp6_mul_dxs_unr_lazyr(fp6_t c, fp6_t a, fp6_t b) {
	fp2_t v0, v1, t0, t1, t2;

	fp2_null(v0);
	fp2_null(v1);
	fp2_null(t0);
	fp2_null(t1);
	fp2_null(t2);

	RLC_TRY {
		fp2_new(v0);
		fp2_new(v1);
		fp2_new(t0);
		fp2_new(t1);
		fp2_new(t2);

		/* v0 = a_0b_0 */
		fp2_mul(v0, a[0], b[0]);

		/* v1 = a_1b_1 */
		fp2_mul(v1, a[1], b[1]);

		/* v2 = a_2b_2 = 0 */

		/* t2 (c0) = v0 + E((a_1 + a_2)(b_1 + b_2) - v1 - v2) */
		fp2_add(t0, a[1], a[2]);
		fp2_mul(t0, t0, b[1]);
		fp2_sub(t0, t0, v1);
		fp2_mul_nor(t2, t0);
		fp2_add(t2, t2, v0);

		/* c1 = (a_0 + a_1)(b_0 + b_1) - v0 - v1 + Ev2 */
		fp2_add(t0, a[0], a[1]);
		fp2_add(t1, b[0], b[1]);
		fp2_mul(c[1], t0, t1);
		fp2_sub(c[1], c[1], v0);
		fp2_sub(c[1], c[1], v1);

		/* c2 = (a_0 + a_2)(b_0 + b_2) - v0 + v1 - v2 */
		fp2_add(t0, a[0], a[2]);
		fp2_mul(c[2], t0, b[0]);
		fp2_sub(c[2], c[2], v0);
		fp2_add(c[2], c[2], v1);

		/* c0 = t2 */
		fp2_copy(c[0], t2);
	} RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY {
		fp2_free(v0);
		fp2_free(v1);
		fp2_free(t0);
		fp2_free(t1);
		fp2_free(t2);
	}
}

#endif

/*============================================================================*/
/* Public definitions                                                         */
/*============================================================================*/

#if FPX_RDC == BASIC || !defined(STRIP)

void fp12_mul_basic(fp12_t c, fp12_t a, fp12_t b) {
	fp6_t t0, t1, t2;

	fp6_null(t0);
	fp6_null(t1);
	fp6_null(t2);

	RLC_TRY {
		fp6_new(t0);
		fp6_new(t1);
		fp6_new(t2);

		/* Karatsuba algorithm. */

		/* t0 = a_0 * b_0. */
		fp6_mul(t0, a[0], b[0]);
		/* t1 = a_1 * b_1. */
		fp6_mul(t1, a[1], b[1]);
		/* t2 = b_0 + b_1. */
		fp6_add(t2, b[0], b[1]);

		/* c_1 = a_0 + a_1. */
		fp6_add(c[1], a[0], a[1]);

		/* c_1 = (a_0 + a_1) * (b_0 + b_1) */
		fp6_mul(c[1], c[1], t2);
		fp6_sub(c[1], c[1], t0);
		fp6_sub(c[1], c[1], t1);

		/* c_0 = a_0b_0 + v * a_1b_1. */
		fp6_mul_art(t1, t1);
		fp6_add(c[0], t0, t1);
	} RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY {
		fp6_free(t0);
		fp6_free(t1);
		fp6_free(t2);
	}
}

void fp12_mul_dxs_basic(fp12_t c, fp12_t a, fp12_t b) {
	fp6_t t0, t1, t2;

	fp6_null(t0);
	fp6_null(t1);
	fp6_null(t2);

	RLC_TRY {
		fp6_new(t0);
		fp6_new(t1);
		fp6_new(t2);

		if (ep2_curve_is_twist() == RLC_EP_DTYPE) {
#if EP_ADD == BASIC
			/* t0 = a_0 * b_0 */
			fp_mul(t0[0][0], a[0][0][0], b[0][0][0]);
			fp_mul(t0[0][1], a[0][0][1], b[0][0][0]);
			fp_mul(t0[1][0], a[0][1][0], b[0][0][0]);
			fp_mul(t0[1][1], a[0][1][1], b[0][0][0]);
			fp_mul(t0[2][0], a[0][2][0], b[0][0][0]);
			fp_mul(t0[2][1], a[0][2][1], b[0][0][0]);
			/* t2 = b_0 + b_1. */
			fp_add(t2[0][0], b[0][0][0], b[1][0][0]);
			fp_copy(t2[0][1], b[1][0][1]);
			fp2_copy(t2[1], b[1][1]);
#elif EP_ADD == PROJC || EP_ADD == JACOB
			/* t0 = a_0 * b_0 */
			fp2_mul(t0[0], a[0][0], b[0][0]);
			fp2_mul(t0[1], a[0][1], b[0][0]);
			fp2_mul(t0[2], a[0][2], b[0][0]);
			/* t2 = b_0 + b_1. */
			fp2_add(t2[0], b[0][0], b[1][0]);
			fp2_copy(t2[1], b[1][1]);
#endif
			/* t1 = a_1 * b_1. */
			fp6_mul_dxs(t1, a[1], b[1]);
		} else {
			/* t0 = a_0 * b_0. */
			fp6_mul_dxs(t0, a[0], b[0]);
#if EP_ADD == BASIC
			/* t1 = a_1 * b_1. */
			fp_mul(t2[0][0], a[1][2][0], b[1][1][0]);
			fp_mul(t2[0][1], a[1][2][1], b[1][1][0]);
			fp2_mul_nor(t1[0], t2[0]);
			fp_mul(t1[1][0], a[1][0][0], b[1][1][0]);
			fp_mul(t1[1][1], a[1][0][1], b[1][1][0]);
			fp_mul(t1[2][0], a[1][1][0], b[1][1][0]);
			fp_mul(t1[2][1], a[1][1][1], b[1][1][0]);
			/* t2 = b_0 + b_1. */
			fp2_copy(t2[0], b[0][0]);
			fp_add(t2[1][0], b[0][1][0], b[1][1][0]);
			fp_copy(t2[1][1], b[0][1][1]);
#elif EP_ADD == PROJC || EP_ADD == JACOB
			/* t1 = a_1 * b_1. */
			fp2_mul(t2[0], a[1][2], b[1][1]);
			fp2_mul_nor(t1[0], t2[0]);
			fp2_mul(t1[1], a[1][0], b[1][1]);
			fp2_mul(t1[2], a[1][1], b[1][1]);
			/* t2 = b_0 + b_1. */
			fp2_copy(t2[0], b[0][0]);
			fp2_add(t2[1], b[0][1], b[1][1]);
#endif
		}
		/* c_1 = a_0 + a_1. */
		fp6_add(c[1], a[0], a[1]);
		/* c_1 = (a_0 + a_1) * (b_0 + b_1) - a_0 * b_0 - a_1 * b_1. */
		fp6_mul_dxs(c[1], c[1], t2);
		fp6_sub(c[1], c[1], t0);
		fp6_sub(c[1], c[1], t1);
		/* c_0 = a_0 * b_0 + v * a_1 * b_1. */
		fp6_mul_art(t1, t1);
		fp6_add(c[0], t0, t1);
	}
	RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	}
	RLC_FINALLY {
		fp6_free(t0);
		fp6_free(t1);
		fp6_free(t2);
	}
}

#endif

#if FPX_RDC == LAZYR || !defined(STRIP)

/////////////////////////////////////////////////////// Copy of basic fp12_mul version
void fp12_mul_lazyr(fp12_t c, fp12_t a, fp12_t b) {
	fp6_t t0, t1, t2;

	fp6_null(t0);
	fp6_null(t1);
	fp6_null(t2);

	RLC_TRY {
		fp6_new(t0);
		fp6_new(t1);
		fp6_new(t2);

		/* Karatsuba algorithm. */

		/* t0 = a_0 * b_0. */
		fp6_mul(t0, a[0], b[0]);
		/* t1 = a_1 * b_1. */
		fp6_mul(t1, a[1], b[1]);
		/* t2 = b_0 + b_1. */
		fp6_add(t2, b[0], b[1]);

		/* c_1 = a_0 + a_1. */
		fp6_add(c[1], a[0], a[1]);

		/* c_1 = (a_0 + a_1) * (b_0 + b_1) */
		fp6_mul(c[1], c[1], t2);
		fp6_sub(c[1], c[1], t0);
		fp6_sub(c[1], c[1], t1);

		/* c_0 = a_0b_0 + v * a_1b_1. */
		fp6_mul_art(t1, t1);
		fp6_add(c[0], t0, t1);
	} RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY {
		fp6_free(t0);
		fp6_free(t1);
		fp6_free(t2);
	}
}


/////////////////////////////////////////////////////// Copy of basic fp12_mul_dxs version
void fp12_mul_dxs_lazyr(fp12_t c, fp12_t a, fp12_t b) {
	fp6_t t0, t1, t2;

	fp6_null(t0);
	fp6_null(t1);
	fp6_null(t2);

	RLC_TRY {
		fp6_new(t0);
		fp6_new(t1);
		fp6_new(t2);

		if (ep2_curve_is_twist() == RLC_EP_DTYPE) {
#if EP_ADD == BASIC
			/* t0 = a_0 * b_0 */
			fp_mul(t0[0][0], a[0][0][0], b[0][0][0]);
			fp_mul(t0[0][1], a[0][0][1], b[0][0][0]);
			fp_mul(t0[1][0], a[0][1][0], b[0][0][0]);
			fp_mul(t0[1][1], a[0][1][1], b[0][0][0]);
			fp_mul(t0[2][0], a[0][2][0], b[0][0][0]);
			fp_mul(t0[2][1], a[0][2][1], b[0][0][0]);
			/* t2 = b_0 + b_1. */
			fp_add(t2[0][0], b[0][0][0], b[1][0][0]);
			fp_copy(t2[0][1], b[1][0][1]);
			fp2_copy(t2[1], b[1][1]);
#elif EP_ADD == PROJC || EP_ADD == JACOB
			/* t0 = a_0 * b_0 */
			fp2_mul(t0[0], a[0][0], b[0][0]);
			fp2_mul(t0[1], a[0][1], b[0][0]);
			fp2_mul(t0[2], a[0][2], b[0][0]);
			/* t2 = b_0 + b_1. */
			fp2_add(t2[0], b[0][0], b[1][0]);
			fp2_copy(t2[1], b[1][1]);
#endif
			/* t1 = a_1 * b_1. */
			fp6_mul_dxs(t1, a[1], b[1]);
		} else {
			/* t0 = a_0 * b_0. */
			fp6_mul_dxs(t0, a[0], b[0]);
#if EP_ADD == BASIC
			/* t1 = a_1 * b_1. */
			fp_mul(t2[0][0], a[1][2][0], b[1][1][0]);
			fp_mul(t2[0][1], a[1][2][1], b[1][1][0]);
			fp2_mul_nor(t1[0], t2[0]);
			fp_mul(t1[1][0], a[1][0][0], b[1][1][0]);
			fp_mul(t1[1][1], a[1][0][1], b[1][1][0]);
			fp_mul(t1[2][0], a[1][1][0], b[1][1][0]);
			fp_mul(t1[2][1], a[1][1][1], b[1][1][0]);
			/* t2 = b_0 + b_1. */
			fp2_copy(t2[0], b[0][0]);
			fp_add(t2[1][0], b[0][1][0], b[1][1][0]);
			fp_copy(t2[1][1], b[0][1][1]);
#elif EP_ADD == PROJC || EP_ADD == JACOB
			/* t1 = a_1 * b_1. */
			fp2_mul(t2[0], a[1][2], b[1][1]);
			fp2_mul_nor(t1[0], t2[0]);
			fp2_mul(t1[1], a[1][0], b[1][1]);
			fp2_mul(t1[2], a[1][1], b[1][1]);
			/* t2 = b_0 + b_1. */
			fp2_copy(t2[0], b[0][0]);
			fp2_add(t2[1], b[0][1], b[1][1]);
#endif
		}
		/* c_1 = a_0 + a_1. */
		fp6_add(c[1], a[0], a[1]);
		/* c_1 = (a_0 + a_1) * (b_0 + b_1) - a_0 * b_0 - a_1 * b_1. */
		fp6_mul_dxs(c[1], c[1], t2);
		fp6_sub(c[1], c[1], t0);
		fp6_sub(c[1], c[1], t1);
		/* c_0 = a_0 * b_0 + v * a_1 * b_1. */
		fp6_mul_art(t1, t1);
		fp6_add(c[0], t0, t1);
	}
	RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	}
	RLC_FINALLY {
		fp6_free(t0);
		fp6_free(t1);
		fp6_free(t2);
	}
}

#endif

void fp12_mul_art(fp12_t c, fp12_t a) {
	fp6_t t0;

	fp6_null(t0);

	RLC_TRY {
		fp6_new(t0);

		/* (a_0 + a_1 * v) * v = a_0 * v + a_1 * v^2 */
		fp6_copy(t0, a[0]);
		fp6_mul_art(c[0], a[1]);
		fp6_copy(c[1], t0);
	} RLC_CATCH_ANY {
		RLC_THROW(ERR_CAUGHT);
	} RLC_FINALLY {
		fp6_free(t0);
	}
}
