*&---------------------------------------------------------------------*
*& Form fill_c_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_c_layout .
*  gs_c_layout-cwidth_opt = 'X'.
  gs_c_layout-zebra = 'X'.
  gs_c_layout-sel_mode = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_c_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_c_fcat .
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZIGS_TCMB_RATE_D'
    CHANGING
      ct_fieldcat            = gt_c_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT gt_c_fcat INTO DATA(gs_c_fcat).
    gs_c_fcat-no_zero = 'X'.
    IF gs_c_fcat-fieldname EQ 'STATUS'.
      gs_c_fcat-icon = 'X'.
    ENDIF.
    MODIFY gt_c_fcat FROM gs_c_fcat.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_and_init_container_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_and_init_container_alv .
  CREATE OBJECT g_c_custom_container
    EXPORTING
      container_name = g_c_container.


  CREATE OBJECT g_c_grid
    EXPORTING
      i_parent      = g_c_custom_container
      i_appl_events = 'X'.


  CALL METHOD g_c_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
  CALL METHOD g_c_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.


  CALL METHOD g_c_grid->set_table_for_first_display
    EXPORTING
      is_layout                     = gs_c_layout
    CHANGING
      it_outtab                     = gt_c_rate
      it_fieldcatalog               = gt_c_fcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc NE 0.
    MESSAGE TEXT-006 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_r_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_r_layout .
*  gs_r_layout-colwidth_optimize = 'X'.
  gs_r_grid_title = 'Kur Bilgileri - TCMB'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_r_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_r_fcat .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = 'ZIGS_TCMB_RATE_D'
      i_client_never_display = 'X'
      i_inclname             = sy-repid
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = gt_r_filedcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE TEXT-007 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

  LOOP AT gt_r_filedcat INTO gs_r_filedcat.
    gs_r_filedcat-no_zero = 'X'.
    CASE gs_r_filedcat-fieldname.
      WHEN 'CURRENCY_CODE' OR 'RATE_DATE'.
        gs_r_filedcat-key = 'X'.
      WHEN 'STATUS'.
        gs_r_filedcat-icon = 'X'.
    ENDCASE.

    MODIFY gt_r_filedcat FROM gs_r_filedcat.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_r_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_r_alv .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_grid_title             = gs_r_grid_title
*     I_GRID"_SETTINGS         =
      is_layout                = gs_r_layout
      it_fieldcat              = gt_r_filedcat
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_c_rate
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE TEXT-008 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS  'STATUS'.
ENDFORM.


FORM user_command USING r_ucomm LIKE sy-ucomm
      rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.


    WHEN '&SAVE_DB'.
      "Save database
      DATA(error) = zigcl_tcmb_helper=>save_db( it_rate = gt_rate ).
      "Check error
      IF error EQ abap_true.
        MESSAGE TEXT-010 TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        MESSAGE TEXT-009 TYPE 'S'.
      ENDIF.


    WHEN '&DWL_EXCEL'.
      "Download as EXCEL
      gv_error = zigcl_tcmb_helper=>download_excel( it_rate = gt_rate g_grid = g_c_grid ).
      "Check error
      IF gv_error EQ 0.
        MESSAGE TEXT-014 TYPE 'S' .
      ELSE.
        MESSAGE TEXT-013 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.


    WHEN '&SEND_MAIL'.
      "Send EXCEL document as mail attachment
      CLEAR: gv_error.
      gv_error = zigcl_tcmb_helper=>send_mail( it_rate = gt_rate g_grid = g_c_grid ).
      IF gv_error EQ abap_false.
        MESSAGE TEXT-016 TYPE 'S'.
      ELSE.
        MESSAGE TEXT-017 TYPE 'E'.
      ENDIF.


    WHEN '&AF_OUTPUT'.
      "Adobe Form Output
      gv_error = zigcl_tcmb_helper=>call_adobeform( it_rate = gt_rate
                                                            iv_date = gv_date
                                                            g_grid = g_c_grid ).
      IF gv_error EQ abap_true.
        MESSAGE TEXT-021 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.


    WHEN '&SF_OUTPUT'.
      "Smartforms Output
      CLEAR : gv_error.
      gv_error = zigcl_tcmb_helper=>call_smartform( it_rate = gt_rate
                                                      iv_date = gv_date
                                                      g_grid = g_c_grid ).
      IF gv_error EQ abap_true.
        MESSAGE TEXT-019 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDFORM.
