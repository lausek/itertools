CLASS zcl_slice DEFINITION
                  FINAL
                  INHERITING FROM zcl_iter
                  FRIENDS zcl_iter.

  PUBLIC SECTION.
    METHODS:
      to_string REDEFINITION,
      has_next  REDEFINITION.

  PROTECTED SECTION.
    DATA:
      w_start TYPE i VALUE 1,
      w_end   TYPE i VALUE 2147483647,
      w_step  TYPE i VALUE 1.

    METHODS:
      next_index REDEFINITION,

      flip_step,
      flip_positions.

  PRIVATE SECTION.
    DATA:
      w_flipped TYPE abap_bool VALUE abap_false,
      w_negated TYPE abap_bool VALUE abap_false.

ENDCLASS.

CLASS zcl_slice IMPLEMENTATION.
  METHOD to_string.

    rw_string = super->to_string( )
                  && COND #( WHEN me->w_flipped = abap_true
                              THEN | FROM={ w_end } TO={ w_start }|
                             ELSE | FROM={ w_start } TO={ w_end }| )
                  && COND #( WHEN me->w_negated = abap_true
                              THEN | STEP={ me->w_step * -1 }|
                             ELSE | STEP={ me->w_step }| ).

  ENDMETHOD.

  METHOD flip_step.

    me->w_negated = boolc( me->w_negated = abap_false ).

    me->w_step = me->w_step * -1.

  ENDMETHOD.

  METHOD flip_positions.

    me->w_flipped = boolc( me->w_flipped = abap_false ).

    DATA(lw_helpme) = me->w_start.
    me->w_start = me->w_end.
    me->w_end = lw_helpme.

  ENDMETHOD.

  METHOD next_index.

    rw_index = COND #( WHEN w_step > 0
                        THEN me->w_start
                       ELSE me->w_end ) + ( me->w_moved * me->w_step ).

  ENDMETHOD.

  METHOD has_next.

    FIELD-SYMBOLS <lfs_table> TYPE STANDARD TABLE.

    ASSIGN me->o_table->* TO <lfs_table>.

    rw_bool = COND #( LET n = me->next_index( ) IN
                      WHEN n NOT BETWEEN me->w_start AND me->w_end
                        OR NOT line_exists( <lfs_table>[ n ] )
                          THEN abap_false
                      ELSE abap_true ).

  ENDMETHOD.

ENDCLASS.