#SQL Merge Speed Tests

This was an experiment to see the speed of various methods of merging data in SQL tables. The quintessential scenario is where an input dataset needs merging with a production table to achieve three objectives:

  1. Existing rows matching a pk in the input dataset are updated, _if necessary_.
  2. New rows not matching a pk in the production table are inserted.
  3. 'Old' rows present in the production table but **not** in the input dataset are 'deleted' (whether that be a soft `update ... set ... where ...` to set a flag or `delete from ... where ...` to actually nuke the row)

There's a bunch of different methods we can use to do this:

  1. Simple flush 'n' fill - I.E. a simple `delete from <table>` followed by `insert into <table>`
  2. Combined UPSERT commands like MSSQL `merge` and MySQL's `on duplicate key update`

The conventional wisdom is that #2 is better than #1 because one command is only going to iterate over the data once, and will almost always therefore be faster (unless there's something really weird going on). I will confirm that, then I want to see which of the two upsert methods works faster. I might also experiment with the "_if necessary_" part of updating data; I.E. is it ever the case that it's better to check somehow if a row needs updating before going ahead and doing it, or should you always just assume that if a pk is matched in a destination table, the row should be updated.

###Software and data

I'm going to try this out with both MySQL and MSSQL - because I use both (MySQL for home projects and MSSQL at work). I will be using the salaries table from the [Employees](https://dev.mysql.com/doc/employee/en/) sample dataset.
