**
** Sample autoboot code fragment
**
** These are the calling conventions for the Diag routine
**
** A7 -- points to at least 2K of stack
** A6 -- ExecBase
** A5 -- ExpansionBase
** A3 -- your board's ConfigDev structure
** A2 -- Base of diag/init area that was copied
** A0 -- Base of your board
**
** Your Diag routine should return a non-zero value in D0 for success.
** If this value is NULL, then the diag/init area that was copied
** will be returned to the free memory pool.
**

    INCLUDE "exec/types.i"
    INCLUDE "exec/nodes.i"
    INCLUDE "exec/resident.i"
    INCLUDE "libraries/configvars.i"

    ; LVO's resolved by linking with library amiga.lib
    XREF   _LVOFindResident

ROMINFO     EQU      0
ROMOFFS     EQU     $4000

* ROMINFO defines whether you want the AUTOCONFIG information in
* the beginning of your ROM (set to 0 if you instead have PALS
* providing the AUTOCONFIG information instead)
*
* ROMOFFS is the offset from your board base where your ROMs appear.
* Your ROMs might appear at offset 0 and contain your AUTOCONFIG
* information in the high nibbles of the first $40 words ($80 bytes).
* Or, your autoconfig ID information may be in a PAL, with your
* ROMs possibly being addressed at some offset (for example $2000)
* from your board base.  This ROMOFFS constant will be used as an
* additional offset from your configured board address when patching
* structures which require absolute pointers to ROM code or data.

*----- We'll store Version and Revision in serial number
VERSION 	EQU	37		; also the high word of serial number
REVISION	EQU	1		; also the low word of serial number

* See the Addison-Wesley Amiga Hardware Manual for more info.

MANUF_ID	EQU	2011		; CBM assigned (2011 for hackers only)
PRODUCT_ID	EQU	1		; Manufacturer picks product ID

BOARDSIZE	EQU	$10000          ; How much address space board decodes
SIZE_FLAG	EQU	3		; Autoconfig 3-bit flag for BOARDSIZE
					;   0=$800000(8meg)  4=$80000(512K)
					;   1=$10000(64K)    5=$100000(1meg)
					;   2=$20000(128K)   6=$200000(2meg)
					;   3=$40000(256K)   7=$400000(4meg)
            CODE

; Exec stuff
AllocMem    EQU -198
InitResident    EQU -102
FindResident    EQU -96
OpenLibrary     EQU -552
CloseLibrary    EQU -414

; Expansion stuff
MakeDosNode     EQU -144
AddDosNode      EQU -150
AddBootNode     EQU -36

; PiSCSI stuff
PiSCSIAddr1     EQU $80000010
PiSCSIDebugMe   EQU $80000020
PiSCSIDriver    EQU $80000040
PiSCSINextPart  EQU $80000044
PiSCSIGetPart   EQU $80000048
PiSCSIGetPrio   EQU $8000004C

*******  RomStart  ***************************************************
**********************************************************************

RomStart:

*******  DiagStart  **************************************************
DiagStart:  ; This is the DiagArea structure whose relative offset from
            ; your board base appears as the Init Diag vector in your
            ; autoconfig ID information.  This structure is designed
            ; to use all relative pointers (no patching needed).
            dc.b    DAC_WORDWIDE+DAC_CONFIGTIME    ; da_Config
            dc.b    0                              ; da_Flags
            dc.w    $4000              ; da_Size
            dc.w    DiagEntry-DiagStart            ; da_DiagPoint
            dc.w    BootEntry-DiagStart            ; da_BootPoint
            dc.w    DevName-DiagStart              ; da_Name
            dc.w    0                              ; da_Reserved01
            dc.w    0                              ; da_Reserved02

*******  Resident Structure  *****************************************
Romtag:
            dc.w    RTC_MATCHWORD      ; UWORD RT_MATCHWORD
rt_Match:   dc.l    Romtag-DiagStart   ; APTR  RT_MATCHTAG
rt_End:     dc.l    EndCopy-DiagStart  ; APTR  RT_ENDSKIP
            dc.b    RTW_COLDSTART      ; UBYTE RT_FLAGS
            dc.b    VERSION            ; UBYTE RT_VERSION
            dc.b    NT_DEVICE          ; UBYTE RT_TYPE
            dc.b    20                 ; BYTE  RT_PRI
rt_Name:    dc.l    DevName-DiagStart  ; APTR  RT_NAME
rt_Id:      dc.l    IdString-DiagStart ; APTR  RT_IDSTRING
rt_Init:    dc.l    Init-RomStart      ; APTR  RT_INIT


******* Strings referenced in Diag Copy area  ************************
DevName:    dc.b    'pi-scsi.device',0,0                      ; Name string
IdString    dc.b    'PISCSI v0.8',0   ; Id string

DosName:    dc.b    'dos.library',0                ; DOS library name
ExpansionName:  dc.b    "expansion.library",0
LibName:        dc.b    "pi-scsi.device",0,0

DosDevName: dc.b    'ABC',0        ; dos device name for MakeDosNode()
                                   ;   (dos device will be ABC:)

            ds.w    0              ; word align

*******  DiagEntry  **************************************************
**********************************************************************
*
*   success = DiagEntry(BoardBase,DiagCopy, configDev)
*   d0                  a0         a2                  a3
*
*   Called by expansion architecture to relocate any pointers
*   in the copied diagnostic area.   We will patch the romtag.
*   If you have pre-coded your MakeDosNode packet, BootNode,
*   or device initialization structures, they would also need
*   to be within this copy area, and patched by this routine.
*
**********************************************************************

DiagEntry:
            align 2
            nop
            nop
            nop
            move.l  #1,PiSCSIDebugMe
            move.l a3,PiSCSIAddr1
            nop
            nop
            nop
            nop
            nop
            nop

            lea      patchTable-RomStart(a0),a1   ; find patch table
            adda.l   #ROMOFFS,a1                  ; adjusting for ROMOFFS

* Patch relative pointers to labels within DiagCopy area
* by adding Diag RAM copy address.  These pointers were coded as
* long relative offsets from base of the DiagArea structure.
*
dpatches:
            move.l   a2,d1           ;d1=base of ram Diag copy
dloop:
            move.w   (a1)+,d0        ;d0=word offs. into Diag needing patch
            bmi.s    bpatches        ;-1 is end of word patch offset table
            add.l    d1,0(a2,d0.w)   ;add DiagCopy addr to coded rel. offset
            bra.s    dloop

* Patches relative pointers to labels within the ROM by adding
* the board base address + ROMOFFS.  These pointers were coded as
* long relative offsets from RomStart.
*
bpatches:
            move.l   a0,d1           ;d1 = board base address
            add.l    #ROMOFFS,d1     ;add offset to where your ROMs are
rloop:
            move.w   (a1)+,d0        ;d0=word offs. into Diag needing patch
            bmi.s   endpatches       ;-1 is end of patch offset table
            add.l   d1,0(a2,d0.w)    ;add ROM address to coded relative offset
            bra.s   rloop

endpatches:
            moveq.l #1,d0           ; indicate "success"
            rts


*******  BootEntry  **************************************************
**********************************************************************

BootEntry:
            align 2
            move.l  #2,PiSCSIDebugMe
            nop
            nop
            nop
            nop
            nop

            lea     DosName(PC),a1          ; 'dos.library',0
            jsr     FindResident(a6)        ; find the DOS resident tag
            move.l  d0,a0                   ; in order to bootstrap
            move.l  RT_INIT(A0),a0          ; set vector to DOS INIT
            jsr     (a0)                    ; and initialize DOS
            rts

*
* End of the Diag copy area which is copied to RAM
*
EndCopy:
*************************************************************************

*************************************************************************
*
*   Beginning of ROM driver code and data that is accessed only in
*   the ROM space.  This must all be position-independent.
*

patchTable:
* Word offsets into Diag area where pointers need Diag copy address added
            dc.w   rt_Match-DiagStart
            dc.w   rt_End-DiagStart
            dc.w   rt_Name-DiagStart
            dc.w   rt_Id-DiagStart
            dc.w   -1

* Word offsets into Diag area where pointers need boardbase+ROMOFFS added
            dc.w   rt_Init-DiagStart
            dc.w   -1

*******  Romtag InitEntry  **********************************************
*************************************************************************

Init:       ; After Diag patching, our romtag will point to this
            ; routine in ROM so that it can be called at Resident
            ; initialization time.
            ; This routine will be similar to a normal expansion device
            ; initialization routine, but will MakeDosNode then set up a
            ; BootNode, and Enqueue() on eb_MountList.
            ;
            align 2
            move.l a6,-(a7)             ; Push A6 to stack
            ;move.w #$00B8,$dff09a       ; Disable interrupts during init
            move.l  #3,PiSCSIDebugMe

            move.l  #11,PiSCSIDebugMe
            movea.l 4,a6
            lea LibName(pc),a1
            jsr FindResident(a6)
            move.l  #10,PiSCSIDebugMe
            cmp.l #0,d0
            bne.s SkipDriverLoad        ; Library is already loaded, jump straight to partitions

            move.l  #4,PiSCSIDebugMe
            movea.l 4,a6
            move.l #$40000,d0
            moveq #0,d1
            jsr AllocMem(a6)            ; Allocate memory for the PiStorm to copy the driver to

            move.l  d0,PiSCSIDriver     ; Copy the PiSCSI driver to allocated memory and patch offsets

            move.l  #5,PiSCSIDebugMe
            move.l  d0,a1
            move.l  #0,d1
            movea.l  4,a6
            add.l #$02c,a1
            jsr InitResident(a6)        ; Initialize the PiSCSI driver

SkipDriverLoad:
            lea ExpansionName(pc),a1
            moveq #0,d0
            jsr OpenLibrary(a6)         ; Open expansion.library to make this work, somehow
            move.l d0,a6

PartitionLoop:
            move.l  #9,PiSCSIDebugMe
            move.l PiSCSIGetPart,d0     ; Get the available partition in the current slot
            beq.s EndPartitions         ; If the next partition returns 0, there's no additional partitions
            move.l d0,a0
            jsr MakeDosNode(a6)
            move.l  #7,PiSCSIDebugMe
            move.l d0,a0
            move.l PiSCSIGetPrio,d0
            move.l #0,d1
            move.l PiSCSIAddr1,a1
            jsr AddBootNode(a6)
            move.l  #8,PiSCSIDebugMe
            move.l #1,PiSCSINextPart    ; Switch to the next partition
            bra.w PartitionLoop


EndPartitions:
            move.l a6,a1
            movea.l 4,a6
            jsr CloseLibrary(a6)
            move.l  #6,PiSCSIDebugMe

            move.l  (a7)+,a6            ; Pop A6 from stack

            ;move.w #$80B8,$dff09a       ; Re-enable interrupts
            moveq.l #1,d0           ; indicate "success"
            rts
            END
