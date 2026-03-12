*&---------------------------------------------------------------------*
*& Report ZTMP_PERFORMANCE1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_performance1.

* Entries: 100 (ITAB1), 1000 (ITAB2)
* Line width: 100
* Both tables sorted by key K

TYPES: BEGIN OF ts_itab,
         k TYPE c LENGTH 100,
       END OF ts_itab,
       ty_itab1 TYPE STANDARD TABLE OF ts_itab WITH DEFAULT KEY.

DATA: itab3 TYPE ty_itab1,
      itab4 TYPE ty_itab1,
      rtime1 TYPE i,
      rtime2 TYPE i.

* Fill tables with 100 and 1000 lines
DATA(itab1) = VALUE ty_itab1( FOR i = 1 WHILE i < 101
                              ( k = i ) ).
DATA(itab2) = VALUE ty_itab1( FOR i = 1 WHILE i < 1001
                              ( k = i ) ).


GET RUN TIME FIELD rtime1.

* nested loop
LOOP AT itab1 INTO DATA(wa1).
  LOOP AT itab2 INTO DATA(wa2)
                WHERE k = wa1-k.
    APPEND wa2 TO itab3.
  ENDLOOP.
ENDLOOP.

GET RUN TIME FIELD rtime1.

GET RUN TIME FIELD rtime2.

* parallel cursors
DATA(j) = 1.
LOOP AT itab1 INTO wa1.
  LOOP AT itab2 INTO wa2 FROM j.
    IF wa2-k <> wa1-k.
      j = sy-tabix.
      EXIT.
    ENDIF.
    APPEND wa2 TO itab4.
  ENDLOOP.
ENDLOOP.
GET RUN TIME FIELD rtime2.


IF itab3 = itab4.
  WRITE 'time passed, ms (nested / parallel cursors):'.
  WRITE / |{ rtime1 } / { rtime2 }|.
ENDIF.
