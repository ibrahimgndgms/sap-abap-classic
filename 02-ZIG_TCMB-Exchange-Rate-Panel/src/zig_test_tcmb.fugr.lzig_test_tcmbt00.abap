*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZIG_TEST_TCMB...................................*
DATA:  BEGIN OF STATUS_ZIG_TEST_TCMB                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZIG_TEST_TCMB                 .
CONTROLS: TCTRL_ZIG_TEST_TCMB
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZIG_TEST_TCMB                 .
TABLES: ZIG_TEST_TCMB                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
