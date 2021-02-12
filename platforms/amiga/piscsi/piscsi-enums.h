#define NUM_UNITS 7
#define PISCSI_OFFSET  0x80000000
#define PISCSI_REGSIZE 0x00010000
#define PISCSI_UPPER   0x80010000

#define SCSIERR_TIMEOUT  (1 << 7)
#define SCSIERR_PARAM    (1 << 6)
#define SCSIERR_ADDRESS  (1 << 5)
#define SCSIERR_ERASESEQ (1 << 4)
#define SCSIERR_CRC      (1 << 3)
#define SCSIERR_ILLEGAL  (1 << 2)
#define SCSIERR_ERASERES (1 << 1)
#define SCSIERR_IDLE     (1 << 0)

enum piscsi_stuff {
    PISCSI_BLOCK_SIZE = 512,
    PISCSI_TRACK_SECTORS = 2048,
};

enum piscsi_cmds {
    PISCSI_CMD_WRITE    = 0x00,
    PISCSI_CMD_READ     = 0x02,
    PISCSI_CMD_DRVNUM   = 0x04,
    PISCSI_CMD_DRVTYPE  = 0x06,
    PISCSI_CMD_BLOCKS   = 0x08,
    PISCSI_CMD_CYLS     = 0x0A,
    PISCSI_CMD_HEADS    = 0x0C,
    PISCSI_CMD_SECS     = 0x0E,
    PISCSI_CMD_ADDR1    = 0x10,
    PISCSI_CMD_ADDR2    = 0x14,
    PISCSI_CMD_ADDR3    = 0x18,
    PISCSI_CMD_ADDR4    = 0x1C,
    PISCSI_CMD_DEBUGME  = 0x20,
    PISCSI_CMD_DRIVER   = 0x40,
    PISCSI_CMD_NEXTPART = 0x44,
    PISCSI_CMD_GETPART  = 0x48,
    PISCSI_CMD_GETPRIO  = 0x4C,
    PISCSI_CMD_WRITE64  = 0x50,
    PISCSI_CMD_READ64   = 0x52,
    PISCSI_DBG_MSG      = 0x1000,
    PISCSI_DBG_VAL1     = 0x1010,
    PISCSI_DBG_VAL2     = 0x1014,
    PISCSI_DBG_VAL3     = 0x1018,
    PISCSI_DBG_VAL4     = 0x101C,
    PISCSI_DBG_VAL5     = 0x1020,
    PISCSI_DBG_VAL6     = 0x1024,
    PISCSI_DBG_VAL7     = 0x1028,
    PISCSI_DBG_VAL8     = 0x102C,
    PISCSI_CMD_ROM      = 0x4000,
};

enum piscsi_dbg_msgs {
    DBG_INIT,
    DBG_OPENDEV,
    DBG_CLOSEDEV,
    DBG_CHS,
    DBG_IOCMD,
    DBG_CLEANUP,
    DBG_BEGINIO,
    DBG_ABORTIO,
    DBG_SCSICMD,
    DBG_SCSI_FORMATDEVICE,
    DBG_SCSI_RDG,
    DBG_SCSI_UNKNOWN_MODESENSE,
    DBG_SCSI_UNKNOWN_COMMAND,
    DBG_SCSIERR,
    DBG_IOCMD_UNHANDLED,
};

#define TD_READ64           24
#define TD_WRITE64          25
#define TD_SEEK64           26
#define TD_FORMAT64         27

#define NSCMD_TD_READ64     0xC000
#define NSCMD_TD_WRITE64    0xC001
#define NSCMD_TD_SEEK64     0xC002
#define NSCMD_TD_FORMAT64   0xC003
