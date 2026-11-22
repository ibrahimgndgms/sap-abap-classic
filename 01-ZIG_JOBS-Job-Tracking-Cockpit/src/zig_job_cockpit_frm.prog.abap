*&---------------------------------------------------------------------*
*& Include          ZIG_JOB_COCKPIT_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form fill_103_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_103_layout .
  gs_103_layout-col_opt = 'X'.
  gs_103_layout-zebra = 'X'.
  gs_103_layout-sel_mode = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_103_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_103_fcat .
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZIGS_JOB'
    CHANGING
      ct_fieldcat      = gt_103_fcat.
  LOOP AT gt_103_fcat INTO DATA(gs_103_fcat).
    CASE gs_103_fcat-fieldname.
      WHEN 'JOB_TITLE'.
        gs_103_fcat-outputlen = 20.
      WHEN 'JOB_DESC'.
        gs_103_fcat-outputlen = 35.
      WHEN 'DEPARTMENT'.
        gs_103_fcat-outputlen = 10.
      WHEN 'STATUS'.
        gs_103_fcat-outputlen = 10.
      WHEN 'PRIORITY'.
        gs_103_fcat-outputlen = 7.
      WHEN 'START_DATE' OR 'DUE_DATE' OR 'CREATED_AT' OR 'CHANGED_AT'.
        gs_103_fcat-datatype = 'DATS'.
        gs_103_fcat-inttype  = 'D'.
    ENDCASE.
    MODIFY gt_103_fcat FROM gs_103_fcat.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_init_103_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_init_103_alv.

  IF go_103_custom_container IS INITIAL.

    DATA top_height TYPE i.
    IF s_prsnl IS INITIAL AND s_dptr IS INITIAL.
      top_height = 10.
    ELSE.
      top_height = 15.
    ENDIF.

    CREATE OBJECT go_103_custom_container
      EXPORTING
        container_name = go_103_container.

    CREATE OBJECT go_splitter
      EXPORTING
        parent  = go_103_custom_container
        rows    = 2
        columns = 1.

    CALL METHOD go_splitter->set_row_height
      EXPORTING
        id     = 1
        height = top_height.

    go_parent_top  = go_splitter->get_container( row = 1 column = 1 ).
    go_parent_grid = go_splitter->get_container( row = 2 column = 1 ).


    CREATE OBJECT go_dyndoc
      EXPORTING
        style = 'PAGE'.


    CALL METHOD go_dyndoc->add_text
      EXPORTING
        text         = 'İŞ LİSTESİ'
        sap_style    = cl_dd_area=>heading
        sap_emphasis = cl_dd_area=>strong.

    CALL METHOD go_dyndoc->new_line.


    CALL METHOD go_dyndoc->add_text
      EXPORTING
        text      = |Tarih : { sy-datum DATE = USER }|
        sap_style = cl_dd_area=>strong.


    IF s_prsnl IS NOT INITIAL.
      CALL METHOD go_dyndoc->new_line.
      CALL METHOD go_dyndoc->add_text
        EXPORTING
          text      = |Sorumlu Personel : { s_prsnl-low }|
          sap_style = cl_dd_area=>strong.
    ENDIF.

    IF s_dptr IS NOT INITIAL.
      CALL METHOD go_dyndoc->new_line.
      CALL METHOD go_dyndoc->add_text
        EXPORTING
          text      = |Departman : { s_dptr-low }|
          sap_style = cl_dd_area=>strong.
    ENDIF.


    CALL METHOD go_dyndoc->display_document
      EXPORTING
        parent        = go_parent_top
        reuse_control = 'X'.


    CREATE OBJECT go_grid
      EXPORTING
        i_parent      = go_parent_grid
        i_appl_events = 'X'.

    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        is_layout       = gs_103_layout
      CHANGING
        it_outtab       = gt_jobs
        it_fieldcatalog = gt_103_fcat.

  ELSE.

    CALL METHOD go_grid->refresh_table_display.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_lock_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_lock_screen .
  CHECK gv_lock = abap_false.

  CALL FUNCTION 'ENQUEUE_EZ_ZIGT_JOBS'
    EXPORTING
      mode_zigt_jobs = 'E'
      mandt          = sy-mandt
      job_no         = zigs_job-job_no
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc EQ 0.
    gv_lock = abap_true.
  ELSE.
    gv_lock = abap_false.
    MESSAGE |Bu iş { sy-msgv1 } kullanıcısı tarafından düzenleniyor. Sadece görüntüleyebilirsiniz. |
                    TYPE 'S' DISPLAY LIKE 'W'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form adjust_screen_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM adjust_screen_fields .
  LOOP AT SCREEN.
    IF screen-group1 = 'GR1'.
      IF gv_lock = abap_true.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form unlock_job
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM unlock_job .

  IF gv_lock = abap_true.
    CALL FUNCTION 'DEQUEUE_EZ_ZIGT_JOBS'
      EXPORTING
        mode_zigt_jobs = 'E'
        mandt          = sy-mandt
        job_no         = zigs_job-job_no.

    gv_lock = abap_false.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form log_delayed_jobs
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM log_delayed_jobs .

  CLEAR: gt_jobs,
          gs_job.
  SELECT * FROM zigt_jobs
           INTO TABLE gt_jobs
           WHERE due_date < sy-datum
           AND ( status = 'DEVAM' OR status = 'YENI' ).

  MODIFY zigt_delay_jobs FROM TABLE gt_jobs.


ENDFORM.
