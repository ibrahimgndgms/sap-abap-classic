*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZIGT_JOB_HISTORY................................*
DATA:  BEGIN OF STATUS_ZIGT_JOB_HISTORY              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZIGT_JOB_HISTORY              .
CONTROLS: TCTRL_ZIGT_JOB_HISTORY
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZIGT_JOB_HISTORY              .
TABLES: ZIGT_JOB_HISTORY               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
