CLASS zcl_iter DEFINITION
                CREATE PRIVATE
                INHERITING FROM object
                FRIENDS zcl_slice.

  PUBLIC SECTION.
    DATA:
      w_moved TYPE i READ-ONLY.

    CLASS-METHODS:
      create_framed CHANGING  ci_table      TYPE STANDARD TABLE OPTIONAL
                    RETURNING VALUE(rw_obj) TYPE REF TO zcl_iter,

      create_frameless CHANGING  ci_table      TYPE STANDARD TABLE
                       RETURNING VALUE(rw_obj) TYPE REF TO zcl_iter.

    METHODS:
      slice         IMPORTING from TYPE i OPTIONAL
                              to   TYPE i OPTIONAL
                              step TYPE i OPTIONAL
                    RETURNING VALUE(rw_obj) TYPE REF TO zcl_slice,

      has_next      RETURNING VALUE(rw_bool) TYPE abap_bool,

      next          RETURNING VALUE(rw_ref) TYPE REF TO data,

      size          RETURNING VALUE(rw_lines) TYPE i,

      to_string     RETURNING VALUE(rw_string) TYPE string.

  PROTECTED SECTION.
    DATA:
      o_table TYPE REF TO data,
      w_index TYPE i VALUE 1.

    METHODS:
      to_repr   RETURNING VALUE(rw_repr) TYPE string,

      set_table CHANGING ci_table TYPE STANDARD TABLE,

      next_index RETURNING VALUE(rw_index) TYPE i
                 RAISING   cx_sy_itab_line_not_found.

ENDCLASS.

CLASS zcl_iter IMPLEMENTATION.
  METHOD create_framed.

    rw_obj = NEW zcl_iter( ).
    rw_obj->set_table( CHANGING ci_table = ci_table ).

  ENDMETHOD.

  METHOD create_frameless.

    DATA lo_copy TYPE REF TO data.
    FIELD-SYMBOLS <lfs_table> TYPE STANDARD TABLE.

    CREATE DATA lo_copy LIKE ci_table.
    ASSIGN lo_copy->* TO <lfs_table>.
    <lfs_table>[] = ci_table[].

    rw_obj = zcl_iter=>create_framed( CHANGING ci_table = <lfs_table> ).

  ENDMETHOD.

  METHOD set_table.

    me->o_table = REF #( ci_table ).

  ENDMETHOD.

  METHOD size.

    FIELD-SYMBOLS <lfs_table> TYPE STANDARD TABLE.
    ASSIGN me->o_table->* TO <lfs_table>.
    rw_lines = lines( <lfs_table> ).

  ENDMETHOD.

  METHOD slice.

    rw_obj = NEW zcl_slice( ).
    rw_obj->o_table = me->o_table.

    rw_obj->w_step = COND #( WHEN step IS NOT SUPPLIED
                              THEN 1
                             WHEN step = 0
                              THEN THROW cx_abap_invalid_param_value( )
                             ELSE step ).

    rw_obj->w_start = COND #( WHEN from IS NOT SUPPLIED
                                THEN 1
                              ELSE from ).

    rw_obj->w_end = COND #( WHEN to IS NOT SUPPLIED
                              OR to IS INITIAL
                              THEN rw_obj->size( )
                            ELSE to ).

*    When end is smaller than start index -> swap
    IF rw_obj->w_end < rw_obj->w_start.

      rw_obj->flip_positions( ).

*      When the step was positive -> make it negative
      IF rw_obj->w_step > 0.
        rw_obj->flip_step( ).
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD to_repr.

    rw_repr = cl_abap_objectdescr=>describe_by_object_ref( me )->get_relative_name( ).

  ENDMETHOD.

  METHOD to_string.

    rw_string = |\\CLASS={ me->to_repr( ) }|.

  ENDMETHOD.

  METHOD next_index.

    rw_index = COND #( WHEN me->w_moved IS INITIAL
                        THEN me->w_index
                       ELSE me->w_index + 1 ).

  ENDMETHOD.

  METHOD has_next.

    FIELD-SYMBOLS <lfs_table> TYPE STANDARD TABLE.
    ASSIGN me->o_table->* TO <lfs_table>.

    rw_bool = COND #( LET n = me->next_index( ) IN
                      WHEN line_exists( <lfs_table>[ n ] )
                        THEN abap_true
                      ELSE abap_false ).

  ENDMETHOD.

  METHOD next.

    FIELD-SYMBOLS <lfs_table> TYPE STANDARD TABLE.
    ASSIGN me->o_table->* TO <lfs_table>.

    me->w_index = me->next_index( ).
    rw_ref = REF #( <lfs_table>[ me->w_index ] ).

    ADD 1 TO me->w_moved.

  ENDMETHOD.

ENDCLASS.