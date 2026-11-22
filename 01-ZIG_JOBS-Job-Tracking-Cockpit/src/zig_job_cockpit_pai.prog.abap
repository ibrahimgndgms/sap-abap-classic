
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command INPUT.
  IF sy-ucomm EQ 'BACK'.
    "Unlock Job
    PERFORM unlock_job.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0102 INPUT.
  DATA: error TYPE abap_bool.

  IF sy-ucomm EQ 'BTN_ADD_JOB'.
    "Authority check
    AUTHORITY-CHECK OBJECT 'ZIG_J_AUTH'
        ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      MESSAGE TEXT-016 TYPE 'E'.
      EXIT.
    ENDIF.

    "Check start and due date
    CLEAR: error.
    error = zigcl_job_utilities=>check_start_due_date( iv_start_date = zigs_job-start_date
                                                       iv_end_date = zigs_job-due_date ).

    IF error EQ abap_true.
      MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.


    "Add new job
    IF zigs_job IS NOT INITIAL.
      CLEAR: error.

      DATA : created_job_no TYPE zigs_job-job_no.

      CALL METHOD zigcl_jop_manager=>create_new_job
        EXPORTING
          is_job        = zigs_job
        IMPORTING
          ev_job_number = created_job_no
        RECEIVING
          rv_error      = error.


      "Update status table
      CLEAR : gs_job_status.
      gs_job_status-job_no = created_job_no.
      gs_job_status-new_status = sy-datum.

      MODIFY zigt_job_history FROM  gs_job_status.

      IF error EQ abap_true.
        MESSAGE TEXT-001 TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        MESSAGE TEXT-002 TYPE 'S'.
        IF rb_1 EQ 'X'.
          "Send information email
          error = zigcl_job_utilities=>send_mail( is_job = zigs_job iv_job_no = created_job_no ).
        ENDIF.
        LEAVE TO SCREEN 0.
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.

  CASE sy-ucomm.
    WHEN '&ADD_JOB'.
      CALL SCREEN 102.
    WHEN '&JOB_DTLS'.
      DATA : lt_index    TYPE lvc_t_row,
             lt_selected TYPE TABLE OF zigs_job,
             ls_selected TYPE zigs_job,
             ls_index    TYPE lvc_s_row.

      IF go_grid IS NOT INITIAL.
        go_grid->check_changed_data(  ).
        go_grid->get_selected_rows( IMPORTING et_index_rows = lt_index ).
      ENDIF.

      IF lines( lt_index ) < 1.
        MESSAGE TEXT-007 TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF lines( lt_index ) > 1.
        MESSAGE TEXT-008 TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.


      IF lt_index IS NOT INITIAL.
        LOOP AT lt_index INTO ls_index.
          CLEAR :zigs_job.
          READ TABLE gt_jobs INTO zigs_job INDEX ls_index-index.
        ENDLOOP.
      ENDIF.
      "Update Job Screen
      CALL SCREEN 0109 .
    WHEN '&JOB_DEL'.

      CLEAR:lt_index, lt_selected.

      IF go_grid IS NOT INITIAL.
        go_grid->check_changed_data(  ).
        go_grid->get_selected_rows( IMPORTING et_index_rows = lt_index ).
      ENDIF.

      IF lt_index IS NOT INITIAL.
        LOOP AT lt_index INTO ls_index.
          READ TABLE gt_jobs INTO ls_selected INDEX ls_index-index.
          IF sy-subrc EQ 0.
            IF ls_selected-status EQ 'T' OR ls_selected-status EQ 'İ'.
              MESSAGE TEXT-011 TYPE 'S' DISPLAY LIKE 'E'.
              EXIT.
            ENDIF.
            INSERT ls_selected INTO TABLE lt_selected.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE TEXT-006 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.


      "Check Authority
      AUTHORITY-CHECK OBJECT 'ZIG_J_AUTH'
        ID 'ACTVT' FIELD '06'.

      IF sy-subrc NE 0.
        CLEAR : ls_selected.
        LOOP AT lt_selected INTO ls_selected.
          IF ls_selected-assigned_to NE sy-uname.
            MESSAGE TEXT-018 TYPE 'E'.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.




      IF lt_selected IS NOT INITIAL.
        CLEAR : error.
        error = zigcl_jop_manager=>delete_jobs( it_delete_jobs = lt_selected ).
        IF error EQ abap_true.
          MESSAGE TEXT-004 TYPE 'S' DISPLAY LIKE 'E'.
        ELSE.
          MESSAGE TEXT-005 TYPE 'S'.
        ENDIF.
      ENDIF.




  ENDCASE.
ENDMODULE.



*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0109  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0109 INPUT.
  CASE sy-ucomm.
    WHEN 'BTN_UPDATE_JOB'.
      "Check authority
      AUTHORITY-CHECK OBJECT 'ZIG_J_AUTH'
        ID 'ACTVT' FIELD '01'.

      IF sy-subrc <> 0 AND zigs_job-assigned_to <> sy-uname.
        MESSAGE TEXT-017 TYPE 'E'.
        EXIT.
      ENDIF.


      "Check Status
      IF gv_previous_status EQ 'YENI' AND zigs_job-status EQ 'TAMAMLANDI'.
        MESSAGE TEXT-013 TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF gv_previous_status EQ 'TAMAMLANDI' AND zigs_job-status EQ 'YENI'.
        MESSAGE TEXT-014 TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF gv_previous_status EQ 'İPTAL' AND ( zigs_job-status EQ 'YENI' OR zigs_job-status EQ 'DEVAM' OR zigs_job-status EQ 'TAMAMLANDI' ).
        MESSAGE TEXT-015 TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      "Check start and due date
      CLEAR: error.
      error = zigcl_job_utilities=>check_start_due_date( iv_start_date = zigs_job-start_date
                                                         iv_end_date = zigs_job-due_date ).

      IF error EQ abap_true.
        MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      CLEAR : error.
      error = zigcl_jop_manager=>update_job( zigs_job ).
      IF error EQ abap_true.
        MESSAGE TEXT-009 TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        MESSAGE TEXT-010  TYPE 'S'.

        CASE zigs_job-status.
          WHEN 'YENI'.
            gs_job_status-new_status = sy-datum.
          WHEN 'TAMAMLANDI'.
            gs_job_status-completed_status = sy-datum.
          WHEN 'İPTAL'.
            gs_job_status-cancel_status = sy-datum.
          WHEN 'DEVAM'.
            gs_job_status-ongoing_status = sy-datum.
        ENDCASE.

        MODIFY zigt_job_history FROM gs_job_status.
      ENDIF.
      "Unlock Job
      PERFORM unlock_job.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_data INPUT.
  IF gt_jobs IS INITIAL.
    LEAVE TO SCREEN 0.
    EXIT.
  ENDIF.
ENDMODULE.
