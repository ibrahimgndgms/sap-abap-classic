*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZIGT_JOB_HISTORY
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZIGT_JOB_HISTORY   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
