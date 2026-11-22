*----------------------------------------------------------------------*
***INCLUDE LZIGT_JOBSF03.
*----------------------------------------------------------------------*

FORM get_next_job_no.
  DATA: lv_next_number TYPE numc5.


  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZIG_JOB_NO'
    IMPORTING
      number                  = lv_next_number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      interval_overflow       = 3
      object_not_found        = 4
      quantity_is_0           = 5
      quantity_is_not_1       = 6
      interval_same_nos       = 7
      number_range_unknown    = 8
      number_range_to_short   = 9
      OTHERS                  = 10.

  IF sy-subrc = 0.
       zigt_jobs-job_no = lv_next_number.
  ENDIF.
ENDFORM.
