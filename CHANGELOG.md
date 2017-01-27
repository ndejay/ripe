HEAD
----

v0.3.0
------

  - [ndejay/ripe#13](http://github.com/ndejay/ripe/issues/13): Change the permissions of the database to the same as the user's umask.
  - [ndejay/ripe#10](http://github.com/ndejay/ripe/issues/10): Support config file for workflows.
  - [ndejay/ripe#8](http://github.com/ndejay/ripe/issues/8): Support ERB task templates.
  - [ndejay/ripe#6](http://github.com/ndejay/ripe/issues/6): Track project_name and user in the ripe metadata db.
  - Track status for workers started locally.
  - Automatically create accessors for `DB::Worker#status`.

v0.2.2
------

This release mostly contains console-related bugfixes.

  - Fix bugs related to displaying workers in tabular format in the console.
  - Fix bug causing ripe to crash when no blocks are prepared for a sample.

<!-- vim: set syntax=markdown: -->
