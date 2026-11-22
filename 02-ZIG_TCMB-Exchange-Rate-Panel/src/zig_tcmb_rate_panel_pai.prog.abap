*&---------------------------------------------------------------------*
*& Include          ZIG_TCMB_RATE_PANEL_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.
  CASE sy-ucomm.


    WHEN '&SAVE_DB'.
      "Save database
      CLEAR: gv_error.
      gv_error = zigcl_tcmb_helper=>save_db( it_rate = gt_rate ).
      "Check error
      IF gv_error EQ abap_true.
        MESSAGE TEXT-010 TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        MESSAGE TEXT-009 TYPE 'S'.
      ENDIF.


    WHEN '&DWL_EXCEL'.
      "Download as EXCEL
      CLEAR: gv_error.
      gv_error = zigcl_tcmb_helper=>download_excel( it_rate = gt_rate g_grid = g_c_grid ).
      "Check error
      IF gv_error EQ 0.
        MESSAGE TEXT-014 TYPE 'S' .
      ELSE.
        MESSAGE TEXT-013 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.


    WHEN '&SEND_MAIL'.
      "Send EXCEL document as mail attachment
*      PERFORM send_email.
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
ENDMODULE.
