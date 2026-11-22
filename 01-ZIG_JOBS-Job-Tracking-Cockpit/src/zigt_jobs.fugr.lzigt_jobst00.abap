*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZIGT_JOBS.......................................*
DATA:  BEGIN OF STATUS_ZIGT_JOBS                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZIGT_JOBS                     .
CONTROLS: TCTRL_ZIGT_JOBS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZIGT_JOBS                     .
TABLES: ZIGT_JOBS                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
