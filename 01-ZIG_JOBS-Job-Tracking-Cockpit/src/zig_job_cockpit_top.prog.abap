*&---------------------------------------------------------------------*
*& Include          ZIG_JOB_COCKPIT_TOP
*&---------------------------------------------------------------------*

TABLES : zigt_personels, zigs_job,zigt_job_history.

"Main Screen Data Definitions
DATA : gs_main_screen_variables TYPE zigs_main_screen_data.


"Add New Job Data Definitions
DATA : gs_job TYPE zigs_job.

DATA: rb_1 TYPE char1,
      rb_2 TYPE char1.

"Show All Jobs Container ALV Definitions
DATA : go_103_container        TYPE scrfname VALUE 'CC_ALL_JOBS',
       go_103_custom_container TYPE REF TO cl_gui_custom_container,
       go_splitter             TYPE REF TO cl_gui_splitter_container,
       go_parent_top           TYPE REF TO cl_gui_container,
       go_parent_grid          TYPE REF TO cl_gui_container,
       go_grid                 TYPE REF TO cl_gui_alv_grid,
       go_dyndoc               TYPE REF TO cl_dd_document.

DATA : gs_103_layout TYPE lvc_s_layo,
       gt_103_fcat   TYPE lvc_t_fcat,
       gs_103_fcat   LIKE LINE OF gt_103_fcat.

DATA: gt_jobs TYPE TABLE OF zigs_job.


"Update Job Data Definitions
DATA : gv_previous_status TYPE zigs_job-status,
       gv_lock            TYPE abap_bool.

"Job Status Table Definitions
DATA : gt_job_status TYPE TABLE OF zigt_job_history,
       gs_job_status LIKE LINE OF gt_job_status.
"Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-019.
  SELECT-OPTIONS : s_jno FOR zigs_job-job_no NO INTERVALS NO-EXTENSION,
  s_dptr FOR zigs_job-department NO INTERVALS NO-EXTENSION,
                   s_sdate FOR zigs_job-start_date,
                   s_prsnl FOR zigs_job-assigned_to NO INTERVALS NO-EXTENSION,
                   s_ddate FOR zigs_job-due_date.

  PARAMETERS : c_new  TYPE check,
               c_con  TYPE check,
               c_com  TYPE check,
               c_crl  TYPE check,
               c_dlyd TYPE check.
SELECTION-SCREEN END OF BLOCK b1.
