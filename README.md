# Itertools
`Itertools` is a collection of classes which add the iterator pattern to your environment.

## Overview

	ZCL_ITER
	|	static create_framed():		// create a framed iterator
	|	static create_frameless(): 	// creates a frameless iterator
	|
	|	slice(): 			// create a slice from that iterator
	|	has_next():			// is there another line?
	|	next():				// gets the next line reference
	|	to_string(): 			// represent the class as string
	|
	|	w_size: 			// amount of elements inside
	|	w_moved:			// how many times was the iterator advanced?
	|
	|--- ZCL_SLICE

## Installation

Preferred installation method is [abapGit](https://github.com/larshp/abapGit).

## How to use

For iterators:

```abap
DATA o_framed     TYPE REF TO zcl_iter.
DATA o_frameless  TYPE REF TO zcl_iter.

o_framed    = zcl_iter=>create_framed( CHANGING ci_table = i_nums ).
o_frameless = zcl_iter=>create_frameless( CHANGING ci_table = i_nums ).
```

For slices call `slice( )` with the optional parameters `from`, `to` or/and `step`:

```abap
DATA o_slice TYPE REF TO zcl_slice.

o_slice = o_framed->slice( ).
" ... or ...
o_slice = o_framed->slice( from = 5 ).
" ... or ...
o_slice = o_framed->slice( from = 1 to = 10 ).
" ... or ...
o_slice = o_framed->slice( from = 1 to = 10 step = -1 ).
```

`slice( step = -1 )` is enough to process the iterator in reversed order.

## Framed vs. Frameless - Which one?
You should use *framed* when:

- you are going to work inside the current stack-frame or a deeper one
- the referenced table does not belong to your stack-frame

You should use *frameless* in:

- any other case

### Why that?
Well, good question. Lets try to demystify it by example:

```abap

FORM create_iter CHANGING fco_iter TYPE REF TO zcl_iter.

	" Use a local table
	DATA(li_nums) = VALUE lcl_test=>t_type_tt( FOR x = 1 THEN x + 1 WHILE x <= 10
					     ( x ) ).

	" Create a framed iterator
	fco_iter = zcl_iter=>create_framed( CHANGING ci_table = li_nums ).

	" Displays just fine...
	lcl_test=>display( fco_iter ).

ENDFORM.

" ...

DATA o_iter TYPE REF TO zcl_iter.

PERFORM create_iter CHANGING o_iter.

lcl_test=>display( o_iter ).

" Whoops... GETWA_NOT_ASSIGNED because o_iter contains a freed reference now :(

```

Our iterator stores the address of the locally declared table and because ABAP destroys local resources at the end of each function, we get a freed reference.

Lets retry with `create_frameless`:

```abap
" Create a frameless iterator
fco_iter = zcl_iter=>create_frameless( CHANGING ci_table = li_nums ).

" ... go outside function ...

lcl_test=>display( o_iter ).

" o_iter keeps its table reference! 
  
```

Instead of plainly saving the address of the specified table, `create_frameless` throws a copy of it on the heap. Now we can pass it around safely.

### Why both?
'cause design-decision-problem. There are some cases where a distinction would be very useful. 

For example: Imagine you have a table with +10.000 entries. You only want to pass it to new frames so copying it would not only cost time, it would also cost twice the amount of memory.
