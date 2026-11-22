*&---------------------------------------------------------------------*
*& Include          ZIG_TCMB_RATE_PANEL_TOP
*&---------------------------------------------------------------------*

TABLES : zigt_mail_adrs,
         zigt_tcmb_rate,
         zigs_tcmb_rate,
         zigs_tcmb_rate_d.

"Selection Screen Design
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN SKIP.
  "Date input
  PARAMETERS : p_date TYPE zigs_tcmb_rate-rate_date DEFAULT sy-datum.

  SELECTION-SCREEN SKIP.
  "ALV Choice
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(20) TEXT-002.
  SELECTION-SCREEN END OF LINE.
  PARAMETERS: r_calv RADIOBUTTON GROUP g1,
              r_ralv RADIOBUTTON GROUP g1.

SELECTION-SCREEN : END OF BLOCK b1.

"Date Variables
DATA : gv_day_number TYPE char1.
DATA : gv_date TYPE d.

"TCMB Url Variable
DATA : gv_url TYPE string.

"Error
DATA : gv_error TYPE abap_bool.

"Get Data Definitions
DATA: gt_rate TYPE TABLE OF zigs_tcmb_rate,
      gs_rate TYPE  zigs_tcmb_rate.

DATA : gv_xml TYPE string.

DATA : gv_client TYPE REF TO if_http_client.


"Container ALV Definitions
DATA : g_c_container        TYPE scrfname VALUE 'CC_ALV',                    "go_c_container
       g_c_grid             TYPE REF TO cl_gui_alv_grid,
       g_c_custom_container TYPE REF TO cl_gui_custom_container.

DATA : gs_c_layout TYPE lvc_s_layo,
       gt_c_fcat   TYPE lvc_t_fcat,
       gs_c_fcat   LIKE LINE OF gt_c_fcat.

DATA: gt_c_rate TYPE TABLE OF zigs_tcmb_rate_d,
      gs_c_rate TYPE  zigs_tcmb_rate_d.
*      gt_r_rate TYPE TABLE OF zigs_tcmb_rate_d,
*      gs_r_rate TYPE  zigs_tcmb_rate_d.

"Reuse ALV Definitions
DATA : gs_r_layout     TYPE slis_layout_alv,
       gs_r_grid_title TYPE lvc_title,
       gt_r_filedcat   TYPE slis_t_fieldcat_alv,
       gs_r_filedcat   LIKE LINE OF gt_r_filedcat.
