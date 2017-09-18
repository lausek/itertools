CLASS zcl_iter  DEFINITION DEFERRED.
CLASS zcl_slice DEFINITION DEFERRED.

*----------------------------------------------------------------------*
*        INCLUDES                                                      *
*----------------------------------------------------------------------*
INCLUDE:  z_lk_itertools_iter_def,
          z_lk_itertools_slice_def,
          z_lk_itertools_iter_imp,
          z_lk_itertools_slice_imp.

*----------------------------------------------------------------------*
*        CLASSES                                                       *
*----------------------------------------------------------------------*
CLASS lcl_test DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      t_type_s  TYPE i,
      t_type_tt TYPE STANDARD TABLE OF i WITH KEY table_line.

    CLASS-METHODS:
      display IMPORTING io_iter TYPE REF TO zcl_iter
                        iw_name TYPE string,

      fetch   IMPORTING iw_amount     TYPE i DEFAULT 10
                          PREFERRED PARAMETER iw_amount
              RETURNING VALUE(rw_ref) TYPE REF TO zcl_iter.

ENDCLASS.

CLASS lcl_test IMPLEMENTATION.

  METHOD display.

    FIELD-SYMBOLS <lfs_line> TYPE t_type_s.

    FORMAT COLOR COL_POSITIVE.
    WRITE: |Displaying "{ iw_name }"-Iterator { io_iter->to_string( ) } :|, /.
    FORMAT COLOR COL_BACKGROUND.

    WHILE io_iter->has_next( ).

      DATA(o_line) = io_iter->next( ).
      ASSIGN o_line->* TO <lfs_line>.

      WRITE: <lfs_line>. NEW-LINE.

    ENDWHILE.

    WRITE: /.

  ENDMETHOD.

  METHOD fetch.

    DATA(i_modified) = VALUE t_type_tt( FOR i = 1 THEN i + 1 WHILE i <= iw_amount
                                        ( i ) ).

    rw_ref = zcl_iter=>create_frameless( CHANGING ci_table = i_modified ).

  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
*        EVENTS                                                        *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  DATA(o_iter) = lcl_test=>fetch( ).

  lcl_test=>display( iw_name = 'Single'
                     io_iter = o_iter->slice( from = 4 to = 4 ) ).

  lcl_test=>display( iw_name = 'Lower'
                     io_iter = o_iter->slice( to = 4 ) ).

  lcl_test=>display( iw_name = 'Middle'
                     io_iter = o_iter->slice( from = 5 to = 6 ) ).

  lcl_test=>display( iw_name = 'Upper'
                     io_iter = o_iter->slice( from = 7 ) ).

  lcl_test=>display( iw_name = 'Reversed'
                     io_iter = o_iter->slice( step = -1 ) ).

  lcl_test=>display( iw_name = 'Half-Reversed'
                     io_iter = o_iter->slice( from = 10 to = 5 ) ).