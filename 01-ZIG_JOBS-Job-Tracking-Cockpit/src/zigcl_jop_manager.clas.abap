class ZIGCL_JOP_MANAGER definition
  public
  final
  create public .

public section.

  class-methods CREATE_NEW_JOB
    importing
      value(IS_JOB) type ZIGS_JOB
    exporting
      value(EV_JOB_NUMBER) type ZIGS_JOB-JOB_NO
    returning
      value(RV_ERROR) type ABAP_BOOL .
  class-methods UPDATE_JOB
    importing
      value(IS_JOB) type ZIGS_JOB
    returning
      value(RV_ERROR) type ABAP_BOOL .
  class-methods DELETE_JOBS
    importing
      value(IT_DELETE_JOBS) type ZIGTT_JOBS
    returning
      value(RV_ERROR) type ABAP_BOOL .
  class-methods GET_ALL_JOBS
    returning
      value(RT_ALL_JOBS) type ZIGTT_JOBS .
  class-methods GET_NEW_JOBS
    returning
      value(RT_NEW_JOBS) type ZIGTT_JOBS .
  class-methods GET_ONGOING_JOBS
    returning
      value(RT_ONGOING_JOBS) type ZIGTT_JOBS .
  class-methods GET_COMPLETED_JOBS
    returning
      value(RT_COMPLETED_JOBS) type ZIGTT_JOBS .
  class-methods GET_CRITICIAL_JOBS
    returning
      value(RT_CRITICAL_JOBS) type ZIGTT_JOBS .
  class-methods GET_DELAYED_JOBS
    returning
      value(RT_DELAYED_JOBS) type ZIGTT_JOBS .
protected section.
private section.
ENDCLASS.



CLASS ZIGCL_JOP_MANAGER IMPLEMENTATION.


  METHOD create_new_job.
    DATA: lv_next_job_number TYPE char10,
          lv_object          TYPE inri-object VALUE 'ZIG_JOB_NO',
          lv_range           TYPE inri-nrrangenr VALUE '01'.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = lv_range
        object      = lv_object
      IMPORTING
        number      = lv_next_job_number.

    IF sy-subrc EQ 0.
      ev_job_number = lv_next_job_number.
      is_job-job_no = lv_next_job_number.
    ENDIF.

    MODIFY zigt_jobs FROM is_job.
    IF sy-subrc EQ 0.
      rv_error = abap_false.
    ELSE.
      rv_error = abap_true.
    ENDIF.


  ENDMETHOD.


  METHOD delete_jobs.

    DELETE zigt_jobs FROM TABLE it_delete_jobs.
    IF sy-subrc EQ 0.
      rv_error = abap_false.
    ELSE.
      rv_error = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_all_jobs.

    SELECT * FROM zigt_jobs INTO TABLE @rt_all_jobs.

  ENDMETHOD.


  method GET_COMPLETED_JOBS.

    SELECT * FROM zigt_jobs
      WHERE status EQ 'TAMAMLANDI'
      INTO TABLE @rt_completed_jobs.

  endmethod.


  METHOD get_criticial_jobs.

    SELECT * FROM zigt_jobs
      WHERE priority EQ 'KRITIK'
      INTO TABLE @rt_critical_jobs.

  ENDMETHOD.


  METHOD get_delayed_jobs.

    SELECT * FROM zigt_jobs
      WHERE  ( status EQ 'DEVAM' OR status EQ 'YENI' )
      AND due_date < @sy-datum
      INTO TABLE @rt_delayed_jobs.

  ENDMETHOD.


  METHOD get_new_jobs.

    SELECT * FROM zigt_jobs
      WHERE status EQ 'YENI'
      AND due_date GE @sy-datum
      INTO table @rt_new_jobs.

  ENDMETHOD.


  METHOD get_ongoing_jobs.

    SELECT * FROM zigt_jobs
    WHERE status EQ 'DEVAM'
    AND due_date >= @sy-datum
    INTO TABLE @rt_ongoing_jobs.

  ENDMETHOD.


  METHOD update_job.
    is_job-changed_at = sy-datum.
    is_job-changed_by = sy-uname.
    UPDATE zigt_jobs FROM is_job.
    IF sy-subrc EQ 0.
      rv_error = abap_false.
    ELSE.
      rv_error = abap_true.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
