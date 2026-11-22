*&---------------------------------------------------------------------*
*& Report ZIG_JOB_COCKPIT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zig_job_cockpit.

INCLUDE zig_job_cockpit_top.
INCLUDE zig_job_cockpit_frm.
INCLUDE zig_job_cockpit_pbo.
INCLUDE zig_job_cockpit_pai.



INITIALIZATION.

START-OF-SELECTION.
  IF sy-batch IS INITIAL.
    "Main Screen
    CALL SCREEN 0103.
  ELSE.
    "Backgroudn JOB
    PERFORM log_delayed_jobs.
  ENDIF.





END-OF-SELECTION.
