class ZIGCL_JOB_UTILITIES definition
  public
  final
  create public .

public section.

  class-methods CHECK_START_DUE_DATE
    importing
      value(IV_START_DATE) type DATUM
      value(IV_END_DATE) type DATUM
    returning
      value(RV_ERROR) type ABAP_BOOL .
  class-methods SEND_MAIL
    importing
      value(IS_JOB) type ZIGS_JOB
      value(IV_JOB_NO) type ZIGS_JOB-JOB_NO
    returning
      value(RV_ERROR) type ABAP_BOOL .
protected section.
private section.
ENDCLASS.



CLASS ZIGCL_JOB_UTILITIES IMPLEMENTATION.


  method CHECK_START_DUE_DATE.

    IF iv_start_date > iv_end_date.
      rv_error = abap_true.
      else.
        rv_error = abap_false.
    ENDIF.

  endmethod.


  METHOD send_mail.

    DATA: lo_send_request  TYPE REF TO cl_bcs,
          lo_document      TYPE REF TO cl_document_bcs,
          lo_recipient     TYPE REF TO if_recipient_bcs,
          lx_bcs_exception TYPE REF TO cx_bcs.

    DATA: lt_message_body TYPE bcsy_text,
          lv_subject      TYPE so_obj_des,
          lv_mail_to      TYPE ad_smtpadr.

    TRY.
        " 1. Gönderi talebi oluştur
        lo_send_request = cl_bcs=>create_persistent( ).

        " 2. Konu başlığı (is_job içindeki alan adınızı yazın)
        lv_subject = |Job Bilgilendirme: { is_job-job_title }|.

        " 3. Mail içeriği (HTML formatında is_job alanlarını okuma)
        APPEND |<html><body>| TO lt_message_body.
        APPEND |<h2>Yeni Bir İş Atandı</h2>| TO lt_message_body.

        APPEND |<div style="font-family: Arial, sans-serif; font-size: 14px; line-height: 1.6;">| TO lt_message_body.
        APPEND |  <hr style="border: 0; border-top: 1px solid #cccccc; margin-bottom: 15px;">| TO lt_message_body.

        " Satır satır liste biçimi
        APPEND |  <p><b>İş Adı:</b> { is_job-job_title }</p>| TO lt_message_body.
        APPEND |  <p><b>İş No:</b> { iv_job_no }</p>| TO lt_message_body.
        APPEND |  <p><b>İş Açıklama:</b> { is_job-job_desc }</p>| TO lt_message_body.
        APPEND |  <p><b>Başlama Tarihi:</b> { is_job-start_date DATE = USER }</p>| TO lt_message_body.
        APPEND |  <p><b>Teslim Tarihi:</b> { is_job-due_date DATE = USER }</p>| TO lt_message_body.

        APPEND |</div>| TO lt_message_body.

        APPEND |</body></html>| TO lt_message_body.

        " 4. Mail dokümanı oluşturma
        lo_document = cl_document_bcs=>create_document(
          i_type    = 'HTM'
          i_text    = lt_message_body
          i_subject = lv_subject ).

        lo_send_request->set_document( lo_document ).

        " 5. Alıcı ekleme (Eğer e-posta adresi de is_job içinde varsa: is_job-email)
        SELECT SINGLE mail FROM zigt_personels INTO @lv_mail_to
          WHERE personel EQ @is_job-assigned_to.


        lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_mail_to ).
        lo_send_request->add_recipient( lo_recipient ).

        " 6. Anlık Gönderim
        " 1. Anlık gönderim parametresini ayrı bir metodla set edin:
        lo_send_request->set_send_immediately( 'X' ).

        " 2. Send metodunu parametresiz (veya sadece i_with_error_screen ile) çağırın:
        DATA(lv_sent) = lo_send_request->send( ).
        COMMIT WORK.

        IF lv_sent = 'X'.
          rv_error = abap_false.
        ENDIF.

      CATCH cx_bcs INTO lx_bcs_exception.
        WRITE: / 'Hata Oluştu:', lx_bcs_exception->get_text( ).
        rv_error = abap_true.
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
