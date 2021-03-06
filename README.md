Table Display
=============

Adds support for displaying your ActiveRecord tables, named scopes, collections, or
plain arrays in a table view when working in rails console, shell, or email template.

`Enumerable#to_table_display` returns the printable strings; `Object#pt` calls `#to_table_display`
on its first argument and puts out the result.

Columns you haven't loaded (eg. from using `:select`) are omitted, and derived/calculated
columns (eg. again, from using `:select`) are added.

Both `#to_table_display` and `Object#pt` methods take `:only`, `:except`, and `:methods` which 
change what attributes/methods are output, like they do on the `#to_xml` method.

The normal output uses `#inspect` on the data values to make them printable, so you can
see what type the values had.  When that's inconvenient or you'd prefer direct display,
you can pass the option `:inspect => false` to disable inspection.


Example
-------

You can call the `to_table_display` method:

    >> puts Project.find(31).tasks.to_table_display
    +----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
    | id | project_id | description            | due_on           | completed_at                   | created_at                     | updated_at                     |
    +----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
    |  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | Tue Mar 24 23:17:05 +1300 2009 | Mon Mar 23 09:11:02 +1300 2009 | Tue Mar 24 23:17:05 +1300 2009 |
    |  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | nil                            | Mon Mar 23 09:11:46 +1300 2009 | Mon Mar 23 09:11:46 +1300 2009 |
    +----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+

Or equivalently, use `pt` (like `pp`, but in a table):

    >> pt Customer.find(31).purchases
    +----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
    | id | project_id | description            | due_on           | completed_at                   | created_at                     | updated_at                     |
    +----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
    |  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | Tue Mar 24 23:17:05 +1300 2009 | Mon Mar 23 09:11:02 +1300 2009 | Tue Mar 24 23:17:05 +1300 2009 |
    |  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | nil                            | Mon Mar 23 09:11:46 +1300 2009 | Mon Mar 23 09:11:46 +1300 2009 |
    +----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+


Like `to_xml`, you can pass a `:methods` option to add the output methods on your models, and you
can pass `:only` or `:except` to (respectively) show only certain columns or show all except certain columns:

    >> puts Customer.find(31).purchases.to_table_display(:only => [:id, :description], :methods => [:met_due_date?])
    +----+------------------------+---------------+
    | id | description            | met_due_date? |
    +----+------------------------+---------------+
    |  1 | "Write a handy plugin" | true          |
    |  2 | "Blog the plugin"      | nil           |
    +----+------------------------+---------------+

`pt` accepts and passes on all options as well:

    >> pt Customer.find(31).purchases, :only => [:id, :description], :methods => [:met_due_date?]
    +----+------------------------+---------------+
    | id | description            | met_due_date? |
    +----+------------------------+---------------+
    |  1 | "Write a handy plugin" | true          |
    |  2 | "Blog the plugin"      | nil           |
    +----+------------------------+---------------+

There's a convenient equivalent syntax for displaying an ordered list of columns, like `:only` and `:methods`:

    >> puts Customer.find(31).purchases.to_table_display :id, :description, :met_due_date?

which provides:

    >> pt Customer.find(31).purchases, :id, :description, :met_due_date?

resulting in the same output as above.


If `:inspect => false` is used, the values will be shown in `#to_s` form rather than `#inspect` form:

    >> pt Customer.find(31).purchases, :only => [:id, :description, :due_on, :completed_at]
    +----+----------------------+------------+--------------------------------+
    | id | description          | due_on     | completed_at                   |
    +----+----------------------+------------+--------------------------------+
    |  1 | Write a handy plugin | 2009-03-25 | Tue Mar 24 23:17:05 +1300 2009 |
    |  2 | Blog the plugin      | 2009-04-05 |                                |
    +----+----------------------+------------+--------------------------------+

It is possible to use objects that respond to `#call` -- such as methods or procs -- to set up columns. They will be
passed the record as their sole argument. If these have names (as with methods), those will be used as the headers.
Otherwise, the default `to_s` behaviour will be used.

Note that in all cases, values whose class descends from `Numeric` are right-aligned, while all other values are left-aligned.

Thanks
------
* Michael Fowler (@mkrfowler)

Copyright (c) 2009-2018 Will Bryant, Sekuda Ltd, released under the MIT license
