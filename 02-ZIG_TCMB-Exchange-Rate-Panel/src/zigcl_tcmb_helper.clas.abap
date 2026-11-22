class ZIGCL_TCMB_HELPER definition
  public
  final
  create public .

public section.

  class-methods SAVE_DB
    importing
      value(IT_RATE) type ZIGTT_TCMB_RATE
    returning
      value(EV_ERROR) type ABAP_BOOL .
  class-methods DOWNLOAD_EXCEL
    importing
      value(IT_RATE) type ZIGTT_TCMB_RATE
      value(G_GRID) type ref to CL_GUI_ALV_GRID
    returning
      value(RV_ERROR) type ABAP_BOOL .
  class-methods SEND_MAIL
    importing
      value(IT_RATE) type ZIGTT_TCMB_RATE
      value(G_GRID) type ref to CL_GUI_ALV_GRID
    returning
      value(RV_ERROR) type ABAP_BOOL .
  class-methods CALL_ADOBEFORM
    importing
      value(IT_RATE) type ZIGTT_TCMB_RATE
      value(IV_DATE) type D
      value(G_GRID) type ref to CL_GUI_ALV_GRID
    returning
      value(RV_ERROR) type ABAP_BOOL .
  class-methods CALL_SMARTFORM
    importing
      value(IT_RATE) type ZIGTT_TCMB_RATE
      value(IV_DATE) type D
      value(G_GRID) type ref to CL_GUI_ALV_GRID
    returning
      value(RV_ERROR) type ABAP_BOOL .
protected section.
private section.
ENDCLASS.



CLASS ZIGCL_TCMB_HELPER IMPLEMENTATION.


  METHOD call_adobeform.

    DATA : lt_index    TYPE lvc_t_row,
           lt_selected TYPE TABLE OF zigs_tcmb_rate.



    IF g_grid IS NOT INITIAL.
      g_grid->check_changed_data(  ).
      g_grid->get_selected_rows( IMPORTING et_index_rows = lt_index ).
    ENDIF.
    IF lt_index IS NOT INITIAL.
      LOOP AT lt_index INTO DATA(ls_index).
        READ TABLE it_rate INTO DATA(ls_selected) INDEX ls_index-index.
        IF sy-subrc EQ 0.
          INSERT ls_selected INTO TABLE lt_selected.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_selected IS NOT INITIAL.
      it_rate = lt_selected.
    ENDIF.


    DATA: lv_form_name    TYPE fpname VALUE 'ZIG_TCMB_RATE_AF',
          lv_fm_name      TYPE rs38l_fnam,
          ls_outputparams TYPE sfpoutputparams.



    ls_outputparams-nodialog = ' '. " 'X' yaparsanız pop-up gelmeden direkt çalışır
    ls_outputparams-preview  = 'X'. " Önizleme ekranını açar

    "Start JOB
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.

    IF sy-subrc <> 0.
      MESSAGE TEXT-020 TYPE 'E'.
    ENDIF.

    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = lv_form_name
          IMPORTING
            e_funcname = lv_fm_name.
      CATCH cx_fp_api_repository
            cx_fp_api_usage
            cx_fp_api_internal.
    ENDTRY.

    CALL FUNCTION lv_fm_name
      EXPORTING
        iv_date        = iv_date
        it_rate        = it_rate
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      rv_error = abap_true.
    ELSE.
      rv_error = abap_false.
    ENDIF.


    "Close JOB
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc EQ 0.
      rv_error = abap_false.
    ELSE.
      rv_error = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD call_smartform.
    DATA : lt_index    TYPE lvc_t_row,
           lt_selected TYPE TABLE OF zigs_tcmb_rate.



    IF g_grid IS NOT INITIAL.
      g_grid->check_changed_data(  ).
      g_grid->get_selected_rows( IMPORTING et_index_rows = lt_index ).
    ENDIF.
    IF lt_index IS NOT INITIAL.
      LOOP AT lt_index INTO DATA(ls_index).
        READ TABLE it_rate INTO DATA(ls_selected) INDEX ls_index-index.
        IF sy-subrc EQ 0.
          INSERT ls_selected INTO TABLE lt_selected.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_selected IS NOT INITIAL.
      it_rate = lt_selected.
    ENDIF.


    DATA : lv_name TYPE rs38l_fnam.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname = 'ZIG_TCMB_RATE_FORM'
      IMPORTING
        fm_name  = lv_name.

    CALL FUNCTION lv_name
      EXPORTING
        iv_date          = iv_date
      TABLES
        it_rate          = it_rate
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.
    IF sy-subrc <> 0.
      rv_error = abap_true.
    ELSE.
      rv_error = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD download_excel.

    DATA : lt_index    TYPE lvc_t_row,
           lt_selected TYPE TABLE OF zigs_tcmb_rate.

    IF g_grid IS NOT INITIAL.
      g_grid->check_changed_data(  ).
      g_grid->get_selected_rows( IMPORTING et_index_rows = lt_index ).
    ENDIF.
    IF lt_index IS NOT INITIAL.
      LOOP AT lt_index INTO DATA(ls_index).
        READ TABLE it_rate INTO DATA(ls_selected) INDEX ls_index-index.
        IF sy-subrc EQ 0.
          INSERT ls_selected INTO TABLE lt_selected.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_selected IS NOT INITIAL.
      it_rate = lt_selected.
    ENDIF.

    DATA : lv_action   TYPE i,
           lv_filename TYPE string,
           lv_path     TYPE string,
           lv_fullpath TYPE string.


    CALL METHOD cl_gui_frontend_services=>file_save_dialog
      EXPORTING
        window_title              = 'Kurları Excel Olarak Kaydet'
        default_extension         = 'csv'
        default_file_name         = 'Kurlar.csv'
        file_filter               = 'CSV Dosyası (*.csv)|*.csv|Tüm Dosyalar (*.*)|*.*'
      CHANGING
        filename                  = lv_filename
        path                      = lv_path
        fullpath                  = lv_fullpath
        user_action               = lv_action
      EXCEPTIONS
        cntl_error                = 1
        error_no_gui              = 2
        not_supported_by_gui      = 3
        invalid_default_file_name = 4
        OTHERS                    = 5.
    IF sy-subrc <> 0.
      MESSAGE TEXT-012 TYPE 'E' DISPLAY LIKE 'E'.
    ENDIF.

    IF lv_action = cl_gui_frontend_services=>action_ok.
      TYPES: BEGIN OF ls_header,
               name TYPE char50,
             END OF ls_header.



      DATA: lt_headers TYPE TABLE OF ls_header,
            ls_header  TYPE ls_header.

      "Add column names into lr_structure
      DATA(lr_struct) = CAST cl_abap_structdescr(
                          cl_abap_typedescr=>describe_by_data( it_rate[ 1 ] ) ).

      "Add column names into ls_header
      LOOP AT lr_struct->components INTO DATA(ls_comp).
        ls_header-name = ls_comp-name.
        IF ls_header-name EQ 'MANDT'.
          CONTINUE.
        ENDIF.
        APPEND ls_header TO lt_headers.
      ENDLOOP.


      DATA: lt_download_tab TYPE TABLE OF string,
            lv_line         TYPE string.

      FIELD-SYMBOLS: <fs_header> TYPE any,
                     <fs_val>    TYPE any.

      " Headers Line
      CLEAR lv_line.
      LOOP AT lt_headers ASSIGNING <fs_header>.
        ASSIGN COMPONENT 1 OF STRUCTURE <fs_header> TO FIELD-SYMBOL(<fs_hname>).
        IF sy-subrc <> 0.
          ASSIGN <fs_header> TO <fs_hname>.
        ENDIF.

        IF lv_line IS INITIAL.
          lv_line = CONV string( <fs_hname> ).
        ELSE.
          lv_line = lv_line && ';' && CONV string( <fs_hname> ).
        ENDIF.
      ENDLOOP.
      APPEND lv_line TO lt_download_tab.

      " Rate Line
      LOOP AT it_rate ASSIGNING FIELD-SYMBOL(<ls_rate>).
        CLEAR lv_line.
        DO.
          ASSIGN COMPONENT sy-index OF STRUCTURE <ls_rate> TO <fs_val>.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.

          IF lv_line IS INITIAL.
            lv_line = CONV string( <fs_val> ).
          ELSE.
            lv_line = lv_line && ';' && CONV string( <fs_val> ).
          ENDIF.
        ENDDO.
        APPEND lv_line TO lt_download_tab.
      ENDLOOP.

      " Download
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename         = lv_fullpath
          filetype         = 'DAT'
          codepage         = '4110' " UTF-8
          write_bom        = 'X'    " UTF-8 BOM
        TABLES
          data_tab         = lt_download_tab
        EXCEPTIONS
          file_write_error = 1
          OTHERS           = 22.
      IF sy-subrc <> 0.
        rv_error = abap_true.

      ELSE.
        rv_error = abap_false.
        MESSAGE TEXT-014 TYPE 'S'.
      ENDIF.
    ELSE.
      rv_error = abap_true.
      MESSAGE TEXT-015 TYPE 'E' DISPLAY LIKE 'E'.
    ENDIF.

  ENDMETHOD.


  method SAVE_DB.
    MODIFY zigt_tcmb_rate FROM TABLE it_rate.

  IF sy-subrc EQ 0.
    ev_error = abap_false.

  ELSE.

  ev_error = abap_true.
  ENDIF.
  endmethod.


  METHOD send_mail.

    DATA : lt_index    TYPE lvc_t_row,
           lt_selected TYPE TABLE OF zigs_tcmb_rate.



    IF g_grid IS NOT INITIAL.
      g_grid->check_changed_data(  ).
      g_grid->get_selected_rows( IMPORTING et_index_rows = lt_index ).
    ENDIF.
    IF lt_index IS NOT INITIAL.
      LOOP AT lt_index INTO DATA(ls_index).
        READ TABLE it_rate INTO DATA(ls_selected) INDEX ls_index-index.
        IF sy-subrc EQ 0.
          INSERT ls_selected INTO TABLE lt_selected.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_selected IS NOT INITIAL.
      it_rate = lt_selected.
    ENDIF.



    DATA: lo_recipient TYPE REF TO if_recipient_bcs VALUE IS INITIAL,
          lo_sender    TYPE REF TO if_sender_bcs VALUE IS INITIAL,
          lr_doc       TYPE REF TO cl_document_bcs,
          lv_html_str  TYPE string,
          lv_xhtml_str TYPE xstring,
          lt_hx        TYPE solix_tab.

    DATA: lv_string      TYPE string,
          lv_line        TYPE string,
          lv_xstring     TYPE xstring,
          lt_content_hex TYPE solix_tab,
          lv_size        TYPE i.

    FIELD-SYMBOLS: <fs_header> TYPE any,
                   <fs_val>    TYPE any.

    DATA: lo_msg TYPE REF TO cl_bcs.
    lo_msg = cl_bcs=>create_persistent( ).

    lo_msg->set_message_subject( 'TCMB Doviz Kur Bilgileri' ).

    lo_sender = cl_cam_address_bcs=>create_internet_address(
                  i_address_string = 'ibrahim.gndgms@mail.com' ).
    TRY.
        lo_msg->set_sender( lo_sender ).
      CATCH cx_send_req_bcs.
    ENDTRY.

    "Get mail addresses from  ZIGT_MAIL_ADRS
    SELECT * FROM zigt_mail_adrs INTO TABLE @DATA(lt_recipients).

    LOOP AT lt_recipients INTO DATA(ls_recipients).
      TRY.
          lo_recipient = cl_cam_address_bcs=>create_internet_address(
                           i_address_string = CONV #( ls_recipients-mail ) ).
          lo_msg->add_recipient( i_recipient = lo_recipient ).
        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

*******************************************
    DATA: lv_rows     TYPE string.

    LOOP AT it_rate INTO DATA(ls_rate).
      CHECK ls_rate-currency_code = 'USD'
                                      OR ls_rate-currency_code = 'EUR'
                                      OR ls_rate-currency_code = 'AUD'
                                      OR ls_rate-currency_code = 'SEK'
                                      OR ls_rate-currency_code = 'CAD'.

      lv_rows = lv_rows &&
                |<tr>| &&
                |<td style ="padding:5px;">{ ls_rate-currency_code }</td>| &&
                |<td style ="padding:5px;">{ ls_rate-forex_buying }</td>| &&
                |<td style ="padding:5px;">{ ls_rate-forex_selling }</td>| &&
                |</tr>|.
    ENDLOOP.
    " Mail body
    lv_html_str = |<html>Sayın Ekip,<br>Döviz kurlarının ekte yer aldığını bilgilerinize sunarız.|
               && |</br>Popüler kurlar aşağıdaki gibidir|
               && |<table border="1" style="border-collapse:collapse; padding:5px;>|
               && |<tr style="background-color:#f2f2f2;"><th style ="padding:5px;">Döviz Türü</th><th style ="padding:5px;">Alış Fiyatı - TL</th><th style ="padding:5px;">Satış Fıyatı-TL</th></tr>|
               && lv_rows
               && |</table>|
               && |<br/><br/><head><meta charset="utf-8"></head><body><ul><li>Tarihe: |
               && |{ sy-datum  DATE = USER }| && |</li></ul><br>Detaylı tablo ektedir</html>|.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = lv_html_str
      IMPORTING
        buffer = lv_xhtml_str
      EXCEPTIONS
        failed = 1
        OTHERS = 2.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lv_xhtml_str
      TABLES
        binary_tab = lt_hx.

    TRY.
        lr_doc = cl_document_bcs=>create_document(
                   i_type    = 'HTM'
                   i_hex     = lt_hx
                   i_subject = 'TCMB Kur Bilgileri' ).
      CATCH cx_root.
    ENDTRY.

    "EXCEL Attachment
    TYPES: BEGIN OF ls_header,
             name TYPE char50,
           END OF ls_header.

    DATA: lt_headers TYPE TABLE OF ls_header,
          ls_header  TYPE ls_header.


    DATA(lo_table_descr)  = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( it_rate ) ).
    DATA(lo_struct_descr) = CAST cl_abap_structdescr( lo_table_descr->get_table_line_type( ) ).

    LOOP AT lo_struct_descr->components INTO DATA(ls_comp).
      IF ls_comp-name = 'MANDT'.
        CONTINUE. " Skip MANDT
      ENDIF.
      ls_header-name = ls_comp-name.
      APPEND ls_header TO lt_headers.
    ENDLOOP.

    "Create headers line from lt_headers
    CLEAR lv_line.
    LOOP AT lt_headers ASSIGNING <fs_header>.
      ASSIGN COMPONENT 1 OF STRUCTURE <fs_header> TO FIELD-SYMBOL(<fs_hname>).
      IF sy-subrc <> 0.
        ASSIGN <fs_header> TO <fs_hname>.
      ENDIF.

      IF lv_line IS INITIAL.
        lv_line = CONV string( <fs_hname> ).
      ELSE.
        lv_line = lv_line && ';' && CONV string( <fs_hname> ).
      ENDIF.
    ENDLOOP.

    lv_string = lv_line.

    " Adding gt_rate data
    LOOP AT it_rate ASSIGNING FIELD-SYMBOL(<ls_rate>).
      CLEAR lv_line.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <ls_rate> TO <fs_val>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        IF lv_line IS INITIAL.
          lv_line = CONV string( <fs_val> ).
        ELSE.
          lv_line = lv_line && ';' && CONV string( <fs_val> ).
        ENDIF.
      ENDDO.

      lv_string = lv_string && cl_abap_char_utilities=>newline && lv_line.
    ENDLOOP.

    " 3. STRING to SOLIX_TAB
    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text     = lv_string
        mimetype = 'text/plain; charset=utf-8'
        encoding = '4110'
      IMPORTING
        buffer   = lv_xstring.

    "For Turkish Characters
    DATA: lv_bom TYPE xstring VALUE 'EFBBBF'.
    lv_xstring = lv_bom && lv_xstring.


    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_xstring
      IMPORTING
        output_length = lv_size
      TABLES
        binary_tab    = lt_content_hex.

    " Adding attachment to the mail
    IF lr_doc IS BOUND.
      TRY.
          lr_doc->add_attachment(
            i_attachment_type    = 'CSV'
            i_attachment_subject = 'Kurlar.csv'
            i_att_content_hex    = lt_content_hex ).


          lo_msg->set_document( lr_doc ).
          DATA: lv_sent TYPE os_boolean.
          " Send Mail
          lv_sent = lo_msg->send( ).
          IF lv_sent = abap_true.
            COMMIT WORK AND WAIT. "
            rv_error = abap_false.
          ELSE.
            ROLLBACK WORK.
            rv_error = abap_true.
          ENDIF.
        CATCH cx_root INTO DATA(lx_root).
          DATA(lv_err_msg) = lx_root->get_text( ).
          MESSAGE lv_err_msg TYPE 'E'.
          rv_error = abap_true.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
