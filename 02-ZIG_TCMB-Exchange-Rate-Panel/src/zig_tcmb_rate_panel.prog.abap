*&---------------------------------------------------------------------*
*& Report ZIG_TCMB_RATE_PANEL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zig_tcmb_rate_panel.

INCLUDE zig_tcmb_rate_panel_top.
INCLUDE zig_tcmb_rate_panel_frm.
INCLUDE zig_tcmb_rate_panel_pbo.
INCLUDE zig_tcmb_rate_panel_pai.

INITIALIZATION.

START-OF-SELECTION.
  gv_date = p_date.
  "Get day number
  gv_day_number = zigcl_get_day_number=>get_day_number( iv_date = gv_date ).

  "Update date
  IF gv_day_number  EQ 6.
    MESSAGE TEXT-022 TYPE 'S'.
    gv_date = gv_date - 1.
  ELSEIF gv_day_number EQ 7.
    MESSAGE TEXT-022 TYPE 'S'.
    gv_date = gv_date - 2.
  ENDIF.

  "Set url
  gv_url = zigcl_set_tcmb_url=>set_url( iv_date = gv_date  ).

  "Get data from www.tcmb.gov.tr
  CALL METHOD zigcl_tcmb_rate_service=>get_data
    EXPORTING
      iv_url        = gv_url
      iv_day_number = gv_day_number
      iv_date       = gv_date
    IMPORTING
      et_c_rate     = gt_c_rate
      et_rate       = gt_rate.


  "Check gt_rate is initial
  IF gt_rate IS NOT INITIAL.
    IF sy-batch IS INITIAL.
      "Normal User
      CASE 'X'.
          "Container ALV
        WHEN r_calv.
          PERFORM fill_c_layout."Fill Container ALV Layout.
          PERFORM create_c_fcat. "Create Container ALV Field Catalog
          CALL SCREEN 0101.

          " Reuse ALV
        WHEN r_ralv.
          PERFORM fill_r_layout."Fill Reuse ALV Layout
          PERFORM create_r_fcat. "Create Reuse ALV Field Catalog
          PERFORM display_r_alv. "Display Reuse ALV
      ENDCASE.
    ELSE.
      "Background JOB
      CLEAR: gv_error.
      gv_error = zigcl_tcmb_helper=>save_db( it_rate = gt_rate ).

      "Check error
      IF gv_error EQ abap_true.
        MESSAGE TEXT-010 TYPE 'E'. "Type 'E' was assigned so that the background job logs successfully.
      ELSE.
        MESSAGE TEXT-009 TYPE 'S'.
      ENDIF.

      CLEAR: gv_error.
      gv_error = zigcl_tcmb_helper=>send_mail( it_rate = gt_rate g_grid =  g_c_grid  ).

      "Check error
      IF gv_error EQ abap_false.
        MESSAGE TEXT-016 TYPE 'S'.
      ELSE.
        MESSAGE TEXT-017 TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

END-OF-SELECTION.
