*&---------------------------------------------------------------------*
*& Include          ZIG_JOB_COCKPIT_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'STATUS_0101'.
* SET TITLEBAR 'xxx'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
  SET PF-STATUS 'STATUS_0102'.

* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INITIAL_VALUES OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE initial_values OUTPUT.
  CLEAR : zigs_job.
  zigs_job-status = 'YENI'.
  zigs_job-changed_at = sy-datum.
  zigs_job-changed_by = sy-uname.
  zigs_job-created_at = sy-datum.
  zigs_job-created_by = sy-uname.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
  SET PF-STATUS 'STATUS-0103'.
  DATA: lt_exclude TYPE TABLE OF sy-ucomm.

  REFRESH lt_exclude.

  AUTHORITY-CHECK OBJECT 'ZIG_J_AUTH'
      ID 'ACTVT' FIELD '01'.


  IF sy-subrc NE 0.
    APPEND '&ADD_JOB' TO lt_exclude.
  ENDIF.

  SET PF-STATUS 'STATUS-0103' EXCLUDING lt_exclude.
  SET TITLEBAR  'TITLE_0100'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0109 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0109 OUTPUT.
  SET PF-STATUS 'STATUS_0109'.
  CLEAR:gs_job_status.
  SELECT SINGLE * FROM zigt_job_history INTO gs_job_status WHERE job_no EQ zigs_job-job_no .


  gv_previous_status = zigs_job-status.

  "Check and Lock Screen
  PERFORM check_lock_screen.
  PERFORM adjust_screen_fields.
ENDMODULE.


*&---------------------------------------------------------------------*
*& Module CHECK_AUTHORITY_0109 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE check_authority_0109 OUTPUT.
  AUTHORITY-CHECK OBJECT 'ZIG_J_AUTH'
      ID 'ACTVT' FIELD '01'.

  IF sy-subrc <> 0.
    IF zigs_job-assigned_to = sy-uname.

      LOOP AT SCREEN.
        IF screen-name = 'ZIGS_JOB-STATUS' OR screen-name = 'BTN_UPDATE_JOB'.
          screen-input = '1'.
        ELSE.
          screen-input = '0'.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    ELSE.
      LOOP AT SCREEN.
        IF screen-name = 'BTN_UPDATE_JOB'.
          screen-invisible = '1'.
        ENDIF.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_JOBS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_jobs OUTPUT.

  DATA : ls_stable TYPE lvc_s_stbl.
  "Status range
  DATA: lr_status TYPE RANGE OF zigt_jobs-status,
        ls_status LIKE LINE OF lr_status.

  ls_status-sign   = 'I'.
  ls_status-option = 'EQ'.
  "Due Date Range
  DATA: lr_ddate TYPE RANGE OF zigt_jobs-due_date,
        ls_ddate LIKE LINE OF lr_ddate.

  IF c_dlyd = abap_true.
    ls_ddate-sign   = 'I'.
    ls_ddate-option = 'LT'.
    ls_ddate-low    = sy-datum.
    APPEND ls_ddate TO lr_ddate.
  ELSE.
    lr_ddate = s_ddate[].
  ENDIF.



  IF c_new = abap_true.
    ls_status-low = 'YENI'.
    APPEND ls_status TO lr_status.
  ENDIF.

  IF c_con = abap_true.
    ls_status-low = 'DEVAM'.
    APPEND ls_status TO lr_status.
  ENDIF.

  IF c_com = abap_true.
    ls_status-low = 'TAMAMLANDI'.
    APPEND ls_status TO lr_status.
  ENDIF.
  "Get Jobs
  CLEAR : gt_jobs.



SELECT * FROM zigt_jobs
    WHERE department IN @s_dptr
      AND job_no IN @s_jno
      AND start_date IN @s_sdate
      AND due_date IN @lr_ddate
      AND status IN @lr_status
      AND ( priority = 'KRITIK' OR @c_crl = @abap_false )
    INTO TABLE @gt_jobs.


  IF sy-subrc NE 0.
    MESSAGE TEXT-020 TYPE 'S' DISPLAY LIKE 'E'.

  ENDIF.

  PERFORM fill_103_layout."Fill 103 Container ALV Layout.
  PERFORM create_103_fcat. "Create 103 Container ALV Field Catalog

  IF go_grid IS INITIAL.
    PERFORM create_init_103_alv.
  ELSE.
    ls_stable-col = 'X'.
    ls_stable-row = 'X'.
    CALL METHOD go_grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CHECK_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE check_data OUTPUT.
*  IF gt_jobs IS INITIAL.
*    LEAVE TO SCREEN 0.
*    EXIT.
*  ENDIF.
ENDMODULE.
