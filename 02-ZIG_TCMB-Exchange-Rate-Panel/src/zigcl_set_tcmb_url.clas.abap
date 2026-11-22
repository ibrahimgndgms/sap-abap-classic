class ZIGCL_SET_TCMB_URL definition
  public
  final
  create public .

public section.

  class-methods SET_URL
    importing
      value(IV_DATE) type D
    returning
      value(RV_URL) type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZIGCL_SET_TCMB_URL IMPLEMENTATION.


  METHOD set_url.
    "Seperate
    DATA(lv_year)  = iv_date+0(4).
    DATA(lv_month) = iv_date+4(2).
    DATA(lv_day)   = iv_date+6(2).


    "Prepare URL
    IF iv_date EQ sy-datum.
      "Selected date
      rv_url = |https://www.tcmb.gov.tr/kurlar/today.xml|.
    ELSE.
      "Today
      rv_url = |https://www.tcmb.gov.tr/kurlar/{ lv_year }{ lv_month }/{ lv_day }{ lv_month }{ lv_year }.xml|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
