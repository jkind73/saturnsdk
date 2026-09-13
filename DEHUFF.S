!***************************************************************************
!*
!*  File:  dehuff.s
!*
!*  Author:  dc
!*
!*  Copyright 1995, Sega of America.  All rights reserved.
!*
!*  This module decompresses data that has been compressed using the
!*  delta/Huffman coding algorithm as implemented by bgcon v1.5 and above.
!*
!*  The algorithm is a standard Huffman coding algorithm, optionally
!*  preceded by delta encoding, in which each value is encoded as the
!*  the difference between the original value and the previous value.
!*
!*  The format of the compressed data is as follows:
!*
!*  Byte 0:  Algorithm code:
!*             0xf0:  No delta-encoding was performed.
!*             0xf1:  Delta-encoding was performed at the byte level.
!*             0xf2:  Delta-encoding was performed at the word level.
!*             0xf3:  Delta-encoding was performed at the long word level.
!*
!*  Bytes 1-3:
!*           Size in bytes of uncompressed data, most-significant byte
!*           first.
!*
!*  Bytes 4-515:
!*           An encoding of the Huffman tree, consisting of 256 two-byte
!*           pairs.  In each pair, the first byte is the value being
!*           encoded, and the second byte is the size of that value's
!*           code.  This information, together with the knowledge that
!*           the codes are ordered according to a depth-first, left-to-
!*           right traversal of the Huffman tree, provides enough
!*           information to reconstruct the values of the Huffman codes
!*           themselves.
!*
!*  Bytes 516-n:
!*           The compressed data.
!*
!***************************************************************************

!***************************************************************************
!*
!*  Constants.
!*
!***************************************************************************

	.equ	LOWEST_CODE,0xf0
	.equ	NO_DELTA,0xf0
	.equ	DELTA_BYTES,0xf1
	.equ	DELTA_WORDS,0xf2
	.equ	DELTA_LONGS,0xf3
	.equ	HIGHEST_CODE,0xf3

	.equ	BAD_HEADER,0xff

!***************************************************************************
!*
!*  This is the top-level decompression routine.
!*
!*  On entry:  r4:  Address of the compressed data.
!*             r5:  Address to which the uncompressed data will be written.
!*
!*  On exit:   r0:  0 if everything worked; < 0 if an error occurred:
!*                    -1:  Bad header; data unrecognizable.
!*                    -2:  Found a Huffman code having a length > 32 bits.
!*
!***************************************************************************

	.align	2
	.global	_DeHuff

_DeHuff:
	mov.l	r8,@-r15
	mov.l	r9,@-r15
	mov.l	r10,@-r15
	mov.l	r11,@-r15
	mov.l	r12,@-r15
	sts.l	pr,@-r15
!
!  Validate the header.
!
	mov.l	@r4+,r6
	mov	r6,r7
	shlr16	r6
	shlr8	r6	!  Isolate algorithm code in r6.
	shll8	r7
	shlr8	r7	!  Isolate uncompressed data size in r7.
	add	r5,r7	!  Compute address of last output byte + 1.

	mov	#LOWEST_CODE,r0
	extu.b	r0,r0
	cmp/hs	r0,r6
	bt.s	TryHi
	mov	#HIGHEST_CODE,r0

BadAlg:	rts
	mov	#BAD_HEADER,r0

TryHi:	extu.b	r0,r0
	cmp/hi	r0,r6
	bt	BadAlg
!
!  Perform the decompression.
!
	mov.l	@(GetAddr,pc),r0
	jsr	@r0
	nop

	mov.l	@(SortAddr,pc),r0
	jsr	@r0
	nop

	mov.l	@(DecomAddr,pc),r0
	jsr	@r0
	nop

	lds.l	@r15+,pr
	mov.l	@r15+,r12
	mov.l	@r15+,r11
	mov.l	@r15+,r10
	mov.l	@r15+,r9
	rts
	mov.l	@r15+,r8

	.align	2

GetAddr:
	.long	GetCodes

SortAddr:
	.long	SortCodes

DecomAddr:
	.long	Decompress

!***************************************************************************
!*
!*  Read the encoded Huffman tree and reconstruct the Huffman codes.
!*
!***************************************************************************

	.align	2

GetCodes:
	mov.l	@(CodesAddr,pc),r8
	mov.l	@(SizeValAddr,pc),r9

	mov	r4,r2	!  Put a pointer to the encoded tree in r2.
	mov.w	@r2+,r1	!  Get the first source value and code size.
	xor	r0,r0	!  The first code is always zero.
	mov.w	r1,@r9	!  Save value and size for later sorting.
	add	#2,r9
	extu.b	r1,r1	!  Isolate the size byte.
	mov.l	r0,@r8	!  Save first code.
	add	#4,r8

	mov	#255,r10	!  Initialize loop counter.
	extu.b	r10,r10

CodeLoop:
	mov.w	@r2+,r11	!  Get the next source value and code size.
	mov.w	r11,@r9	!  Save them for later sorting.
	add	#2,r9
	extu.b	r11,r11	!  Isolate the size byte.
	subv	r11,r1	!  Get difference between size and last size.
	tst	r1,r1	!  Are they equal?
	bt.s	SaveCode	!  Yup:  next code = prev. code + 1.
	add	#1,r0

	cmp/pl	r1	!  Nope:  is new code bigger?
	bf	NewIsBigger

	add	#-1,r0	!  Nope:  Shift old code right, then add 1.
NewIsSmaller:
	dt	r1
	bf.s	NewIsSmaller
	shlr	r0
	bra	SaveCode
	add	#1,r0

NewIsBigger:
	neg	r1,r1
BiggerLoop:
	dt	r1
	bf.s	BiggerLoop
	shll	r0

SaveCode:
	mov.l	r0,@r8
	add	#4,r8
	dt	r10
	bf.s	CodeLoop:
	mov	r11,r1

	rts
	mov	r2,r4	!  r4 now points at the compressed data.

!***************************************************************************
!*
!*  Sort the Huffman codes in order of ascending length.
!*
!***************************************************************************

	.align	2

SortCodes:
	mov.l	@(CodesAddr,pc),r8
	mov.l	@(SizeValAddr,pc),r9
	mov	#1,r0
	mov.l	@(CodesEndAddr,pc),r1
!
!  Since we assume that the largest possible code length is 32 bits, we'll
!  make 32 passes over the codes.  On the first pass, all codes with length
!  1 will be moved to the front; on the second pass, codes with length 2
!  will be moved to spots just after the codes with length 1, etc.
!
OuterLoop:
	mov.w	@r9,r2
	extu.b	r2,r3
	cmp/eq	r0,r3	!  Is the next code already sorted?
	bf	Continue	!  Nope:  Go sort.
	add	#4,r8	!  Yup:  leave it be.
	cmp/eq	r8,r1	!  Make sure we don't fall off the end.
	bf.s	OuterLoop
	add	#2,r9
	rts
	nop

Continue:
	mov	r8,r10
	mov	r9,r11

	add	#4,r10
	cmp/eq	r10,r1
	bt.s	Done
	add	#2,r11

InnerLoop:
	mov.w	@r11,r2	!  Fetch the next size/value pair.
	extu.b	r2,r3	!  Isolate the size.
	cmp/eq	r0,r3	!  Is this the size we're looking for?
	bf.s	NoSwap	!  Nope:  don't move it.

	mov.w	@r9,r3	!  The current code is of the length we're
	mov.w	r2,@r9	!    looking for, so exchange it with the
	mov.w	r3,@r11	!    first unsorted code.
	mov.l	@r8,r2
	mov.l	@r10,r3
	mov.l	r2,@r10
	mov.l	r3,@r8

	add	#4,r8
	add	#2,r9

	cmp/eq	r8,r10
	bf.s	InnerLoop
	nop

NoSwap:
	add	#4,r10
	cmp/eq	r10,r1
	bf.s	InnerLoop
	add	#2,r11

PassDone:
	cmp/eq	#31,r0	!  Are we done?
	bf.s	OuterLoop
	add	#1,r0

Done:	rts
	nop

!***************************************************************************
!*
!*  Use the list of sorted codes to decompress something.
!*
!*  On entry:  r4:  Pointer to first byte of compressed data.
!*             r5:  Pointer to first byte of uncompressed data.
!*             r6:  Algorithm code.
!*             r7:  Pointer to last byte of uncompressed data + 1.
!*
!***************************************************************************

	.align	2

Decompress:
	mov.l	@r4+,r2	!  Get first four compressed bytes.
	mov	#32,r1	!  Initialize right-shift count.
	swap.b	r2,r2	!  Reverse the order of the bytes.
	swap.w	r2,r2
	swap.b	r2,r2

	mov	r5,r12	!  Save output pointer for later.
DecomLoop:
	mov.l	@(CodesAddr,pc),r8
	mov.l	@(SizeValAddr,pc),r9
	add	#1,r9	!  Point at first size byte.
	mov	#0,r10	!  Initialize next Huffman code to zero.
	mov.b	@r9,r3	!  Get first size byte.

GetBit:	cmp/hi	r3,r1	!  Will we be needing to fetch more data?
	bt.s	BitLp3	!  Nope:  use the second loop.

BitLp1:	rotcr	r2	!  Yup:  use the first loop, then fetch a
	rotcl	r10	!    new batch of data and fall through into
	dt	r1	!    second loop, after checking to see if
	bf.s	BitLp1	!    there are still more bits to add.
	dt	r3

	mov.l	@r4+,r2	!  Get next four compressed bytes.
	mov	#32,r1	!  Initialize right-shift count.
	swap.b	r2,r2	!  Reverse the order of the bytes.
	swap.w	r2,r2
	bt.s	B4Srch	!  T=1:  The code is finished.
	swap.b	r2,r2

BitLp2:	rotcr	r2
BitLp3:	rotcl	r10
	dt	r3
	bf.s	BitLp2
	dt	r1

B4Srch:	mov.b	@r9,r3	!  Reset r3 to size of current code.
Search:	mov.l	@r8+,r11	!  Get next Huffman code.
	cmp/eq	r10,r11	!  Is this the code we're looking for?
	bt.s	Emit	!  Yup:  now we can emit an output byte.
	add	#2,r9
	mov.b	@r9,r11	!  Get next length byte.
	cmp/eq	r3,r11	!  Has the length increased?
	bt.s	Search	!  Nope:  check the next code.
	sub	r3,r11	!  Yup:  Compute the number of new bits to
	bra	GetBit	!    add to our Huffman code and go back and
	mov	r11,r3	!    get 'em.

Emit:	add	#-3,r9	!  Back up to point at the value that the
	mov.b	@r9,r0	!    just-found Huffman code encoded.
	mov.b	r0,@r5
	add	#1,r5
	cmp/eq	r5,r7
	bf.s	DecomLoop
	nop
!
!  See if the original data was delta-compressed.
!
	exts.b	r6,r0
	cmp/eq	#NO_DELTA,r0
	bt.s	DeltaDone
	add	#-1,r7	!  Point r7 to last byte to be decompressed.

	cmp/eq	#DELTA_BYTES,r0
	bf.s	NotBytes
	nop

	mov.b	@r12+,r1
ByteLoop:
	mov.b	@r12,r2
	add	r2,r1
	mov.b	r1,@r12
	cmp/hs	r7,r12	!  Was that the last byte?
	bf.s	ByteLoop
	add	#1,r12

	rts
	xor	r0,r0

NotBytes:
	cmp/eq	#DELTA_WORDS,r0
	bf.s	NotWords
	nop

	mov.w	@r12+,r1
WordLoop:
	mov.w	@r12,r2
	add	r2,r1
	mov.w	r1,@r12
	cmp/hs	r7,r12	!  Was that the last word?
	bf.s	WordLoop
	add	#2,r12

	rts
	xor	r0,r0

NotWords:
	cmp/eq	#DELTA_LONGS,r0
	bf.s	DeltaDone

	mov.l	@r12+,r1
LongLoop:
	mov.l	@r12,r2
	add	r2,r1
	mov.l	r1,@r12
	cmp/hs	r7,r12	!  Was that the last long word?
	bf.s	LongLoop
	add	#4,r12

DeltaDone:
	rts
	xor	r0,r0

	.align	2

CodesAddr:
	.long	Codes
CodesEndAddr:
	.long	Codes+1024
SizeValAddr:
	.long	SizeVals

!***************************************************************************
!*
!*  Tables of Huffman codes, code lengths, and values being encodes.
!*
!***************************************************************************

	.align	2

Codes:
	.fill	256,4,0
SizeVals:
	.fill	256,2,0
