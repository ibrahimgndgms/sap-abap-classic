*&---------------------------------------------------------------------*
*& Include          ZIG_TCMB_RATE_PANEL_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  DATA : ls_stable TYPE lvc_s_stbl.

  SET PF-STATUS 'STATUS-0101'.
  IF g_c_grid IS INITIAL.
    PERFORM create_and_init_container_alv.
  ELSE.
    ls_stable-col = 'X'.
    ls_stable-row = 'X'.
    CALL METHOD g_c_grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable.
  ENDIF.
ENDMODULE.
