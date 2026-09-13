/******************************************************************************
 *	ƒ\ƒtƒgƒEƒFƒAƒ‰ƒCƒuƒ‰ƒŠ
 *
 *	Copyright (c) 1994,1995 SEGA
 *
 * Library	:‚o‚b‚lE‚`‚c‚o‚b‚lÄ¶ƒ‰ƒCƒuƒ‰ƒŠ
 * Module 	:‚`‚o‚b‚lƒ`ƒƒƒ“ƒNˆ—
 * File		:pcm_aif2.c
 * Date		:1994-12-08
 * Version	:1.00
 * Auther	:Y.T
 *
 ****************************************************************************/
#include "pcm_msub.h"
#include "pcm_aif.h"

extern void pcm_AudioProcessAdpcm(PcmHn hn);

/*******************************************************************
y‹@@”\z
	ƒƒ‚ƒŠÄ¶^‚Pƒ`ƒƒƒ“ƒNˆ—FAdpcm Chunk ‚ÌADPCM‘Î‰žˆ—
yˆø@”z
	‚È‚µ
y–ß‚è’lz
	‚È‚µ
y”õ@lz
	ŠÖ”ƒ|ƒCƒ“ƒ^ pcm_chunk_adpcm_fp ‚ÉÝ’è‚³‚ê‚ÄƒR[ƒ‹‚³‚ê‚é
*******************************************************************/
void pcm_ChunkAdpcm(PcmHn hn, PcmAdpcmChunk *chunk)
{
	PcmWork		*work 	= *(PcmWork **)hn;
	PcmPara		*para 	= &work->para;
	PcmStatus	*st 	= &work->status;

	st->media_offset = (Sint32)chunk + 4*4 - (Sint32)para->ring_addr;

	st->info.data_type = PCM_DATA_TYPE_ADPCM_SCT;

	/* ƒTƒ“ƒvƒŠƒ“ƒOƒrƒbƒg” */
	/* file ni ha 4[bit/sample] to kai te a ru */
	st->info.sampling_bit = 16;		/* 16 [bit/sample] */

	/* ƒI[ƒfƒBƒIˆ—ŠÖ”ƒ|ƒCƒ“ƒ^‚ÌÝ’è */
	st->audio_process_fp = pcm_AudioProcessAdpcm;
}
