class ZIGCL_TCMB_RATE_SERVICE definition
  public
  final
  create public .

public section.

  class-methods GET_DATA
    importing
      value(IV_URL) type STRING
      value(IV_DAY_NUMBER) type CHAR01
      value(IV_DATE) type D
    exporting
      value(ET_C_RATE) type ZIGTT_TCMB_RATE_D
      value(ET_RATE) type ZIGTT_TCMB_RATE .
protected section.
private section.
ENDCLASS.



CLASS ZIGCL_TCMB_RATE_SERVICE IMPLEMENTATION.


  METHOD get_data.
    DATA : lv_client TYPE REF TO if_http_client.

    DATA: ls_c_rate TYPE zigs_tcmb_rate_d,
          ls_rate   TYPE  zigs_tcmb_rate.


    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = iv_url
      IMPORTING
        client             = lv_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
      MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

    lv_client->request->set_header_field( name = '~request_method' value = 'GET' ).

    "Get request
    CALL METHOD lv_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        OTHERS                     = 5.
    IF sy-subrc <> 0.
      MESSAGE TEXT-004 TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.


    "Prepare client-receive:
    CALL METHOD lv_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4.



    DATA: l_ixml          TYPE REF TO if_ixml,
          l_streamfactory TYPE REF TO if_ixml_stream_factory,
          l_istream       TYPE REF TO if_ixml_istream,
          l_parser        TYPE REF TO if_ixml_parser,
          l_document      TYPE REF TO if_ixml_document,
          lv_xml_x        TYPE xstring.

    "GET HTML
    lv_xml_x = lv_client->response->get_data( ).
    l_ixml = cl_ixml=>create( ).

* Creating a stream factory
    l_streamfactory = l_ixml->create_stream_factory( ).

* wrap the xstring containing the manifest file into an input stream
    l_istream = l_streamfactory->create_istream_xstring( string = lv_xml_x ).

* Creating a document
    l_document = l_ixml->create_document( ).

* Create a Parser
    l_parser = l_ixml->create_parser( stream_factory = l_streamfactory
                                      istream        = l_istream
                                      document       = l_document ).

* Parse the stream
    IF l_parser->parse( ) NE 0.
      MESSAGE TEXT-005 TYPE 'E'.
      EXIT.
    ENDIF.

    DATA: curr_node_collection TYPE REF TO if_ixml_node_collection,
          curr_node_iterator   TYPE REF TO if_ixml_node_iterator,
          curr_node            TYPE REF TO if_ixml_node,
          curr_nodemap         TYPE REF TO if_ixml_named_node_map,
          curr_attr            TYPE REF TO if_ixml_node,
          curr_node_list       TYPE REF TO if_ixml_node_list,
          lv_val               TYPE string,
          lv_length            TYPE i,
          lv_indx              TYPE i.

    curr_node_collection = l_document->get_elements_by_tag_name( name = 'Currency' ).
    curr_node_iterator = curr_node_collection->create_iterator( ).
    curr_node = curr_node_iterator->get_next( ).

    "Prev Day
    DATA lv_prev_day TYPE d.
    IF iv_day_number EQ 1.
      lv_prev_day = iv_date - 3.
    ELSE.
      lv_prev_day = iv_date - 1.
    ENDIF.


    "Get previous data

    DATA lt_alv_rate TYPE TABLE OF zigt_tcmb_rate.
    SELECT  * FROM zigt_tcmb_rate INTO TABLE lt_alv_rate WHERE rate_date EQ lv_prev_day.



    WHILE curr_node IS NOT INITIAL.

      curr_nodemap = curr_node->get_attributes( ).
      curr_attr = curr_nodemap->get_named_item( name = 'CurrencyCode' ).

      CLEAR lv_val.
      CLEAR : ls_rate,ls_c_rate.
      IF curr_attr IS NOT INITIAL.
        lv_val = curr_attr->get_value( ).
        ls_rate-currency_code = lv_val.
        ls_c_rate-currency_code = lv_val.
      ENDIF.

      curr_node_list = curr_node->get_children( ).
      CLEAR lv_length.
      lv_length = curr_node_list->get_length( ).
      DO lv_length TIMES.
        lv_indx = sy-index - 1.
        curr_attr = curr_node_list->get_item( lv_indx ).

        CLEAR lv_val.
        IF curr_attr IS NOT INITIAL.
          lv_val = curr_attr->get_name( ).
          "Para birimler . virgül ile değiştirildi EXCEL'e aktarırken sorun yaşanmaması için
          CASE lv_val.
            WHEN 'Unit'.
              ls_rate-unit = curr_attr->get_value( ).
              ls_c_rate-unit = curr_attr->get_value( ).
            WHEN 'Isim'.
              ls_rate-name = curr_attr->get_value( ).
              ls_c_rate-name = curr_attr->get_value( ).
            WHEN 'CurrencyName'.
              ls_rate-currency_name = curr_attr->get_value( ).
              ls_c_rate-currency_name = curr_attr->get_value( ).
            WHEN 'ForexBuying'.
              ls_rate-forex_buying = curr_attr->get_value( ).
              REPLACE ALL OCCURRENCES OF '.' IN ls_rate-forex_buying WITH ','.
              DATA(lv_forex_buying) = curr_attr->get_value( ).
              IF lv_forex_buying IS NOT INITIAL.
                ls_c_rate-forex_buying = lv_forex_buying.
              ENDIF.
            WHEN 'ForexSelling'.
              ls_rate-forex_selling = curr_attr->get_value( ).
              REPLACE ALL OCCURRENCES OF '.' IN ls_rate-forex_selling WITH ','.
              DATA(lv_forex_selling) = curr_attr->get_value( ).
              IF lv_forex_selling IS NOT INITIAL.
                ls_c_rate-forex_selling = lv_forex_selling.
              ENDIF.
            WHEN 'BanknoteBuying'.
              ls_rate-banknote_buying = curr_attr->get_value( ).
              REPLACE ALL OCCURRENCES OF '.' IN ls_rate-banknote_buying WITH ','.
              DATA(lv_banknote_buying) = curr_attr->get_value( ).
              IF lv_banknote_buying IS NOT INITIAL.
                ls_c_rate-banknote_buying = lv_banknote_buying.
              ENDIF.
            WHEN 'BanknoteSelling'.
              ls_rate-banknote_selling = curr_attr->get_value( ).
              REPLACE ALL OCCURRENCES OF '.' IN ls_rate-banknote_selling WITH ','.
              DATA(lv_banknote_selling) = curr_attr->get_value( ).
              IF lv_banknote_selling IS NOT INITIAL.
                ls_c_rate-banknote_selling = lv_banknote_selling.
              ENDIF.

            WHEN 'CrossRateUSD'.
              ls_rate-cross_rate_usd = curr_attr->get_value( ).
              ls_c_rate-cross_rate_usd = curr_attr->get_value( ).
            WHEN 'CrossRateOther'.
              ls_rate-cross_rate_others = curr_attr->get_value( ).
              ls_c_rate-cross_rate_others = curr_attr->get_value( ).
          ENDCASE.
        ENDIF.
      ENDDO.
      curr_node = curr_node_iterator->get_next( ).

      ls_rate-rate_date = IV_DATE.
      ls_c_rate-rate_date = IV_DATE.

      "Get previous rate from internal table
      READ TABLE lt_alv_rate INTO DATA(ls_alv_rate) WITH KEY currency_code = ls_c_rate-currency_code rate_date = lv_prev_day.


      "For comparison
      IF ls_alv_rate IS NOT INITIAL.
        DATA: lv_prev    TYPE string,
              lv_current TYPE string.

        TYPES : ty_pack TYPE p LENGTH 8 DECIMALS 4.
        " Önce string'e çeviriyoruz
        lv_prev = |{ ls_alv_rate-forex_buying }|.
        lv_current = |{ ls_c_rate-forex_buying }|.


        REPLACE ALL OCCURRENCES OF ',' IN lv_current WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_prev WITH '.'.
        IF CONV ty_pack( lv_prev ) > CONV ty_pack( lv_current ).
          ls_c_rate-status = icon_incoming_object.
        ELSEIF CONV ty_pack( lv_current ) EQ CONV ty_pack( lv_prev ).
          ls_c_rate-status = icon_equal_red.
        ELSE.
          ls_c_rate-status = icon_outgoing_object.
        ENDIF.
      ELSE.
        ls_c_rate-status = ''.
      ENDIF.

      "Instert rate information to internal tables
      INSERT ls_rate INTO TABLE et_rate.
      INSERT ls_c_rate INTO TABLE et_c_rate.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
