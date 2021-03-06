/* kernel atomic64 operations
 *
 * For an explanation of how atomic ops work in this arch, see:
 *   Documentation/frv/atomic-ops.txt
 *
 * Copyright (C) 2009 Red Hat, Inc. All Rights Reserved.
 * Written by David Howells (dhowells@redhat.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version
 * 2 of the License, or (at your option) any later version.
 */

#include <asm/spr-regs.h>

	.text
	.balign 4


###############################################################################
#
# uint64_t __xchg_64(uint64_t i, uint64_t *v)
#
###############################################################################
	.globl		__xchg_64
        .type		__xchg_64,@function
__xchg_64:
	or.p		gr8,gr8,gr4
	or		gr9,gr9,gr5
0:
	orcc		gr0,gr0,gr0,icc3		/* set ICC3.Z */
	ckeq		icc3,cc7
	ldd.p		@(gr10,gr0),gr8			/* LDD.P/ORCR must be atomic */
	orcr		cc7,cc7,cc3			/* set CC3 to true */
	cstd.p		gr4,@(gr10,gr0)		,cc3,#1
	corcc		gr29,gr29,gr0		,cc3,#1	/* clear ICC3.Z if store happens */
	beq		icc3,#0,0b
	bralr

	.size		__xchg_64, .-__xchg_64

###############################################################################
#
# uint64_t __cmpxchg_64(uint64_t test, uint64_t new, uint64_t *v)
#
###############################################################################
	.globl		__cmpxchg_64
        .type		__cmpxchg_64,@function
__cmpxchg_64:
	or.p		gr8,gr8,gr4
	or		gr9,gr9,gr5
0:
	orcc		gr0,gr0,gr0,icc3		/* set ICC3.Z */
	ckeq		icc3,cc7
	ldd.p		@(gr12,gr0),gr8			/* LDD.P/ORCR must be atomic */
	orcr		cc7,cc7,cc3
	subcc		gr8,gr4,gr0,icc0
	subcc.p		gr9,gr5,gr0,icc1
	bnelr		icc0,#0
	bnelr		icc1,#0
	cstd.p		gr10,@(gr12,gr0)	,cc3,#1
	corcc		gr29,gr29,gr0		,cc3,#1	/* clear ICC3.Z if store happens */
	beq		icc3,#0,0b
	bralr

	.size		__cmpxchg_64, .-__cmpxchg_64

