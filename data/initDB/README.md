At this place, all database dumps are saved at ``make server-down``.

On ``make server-up``, all database dumps are restored. Make sure that the ``create database`` command is called within the file.

The restore will only work if the server has been completely shut down previously, or the volume ``..._db-data-dir`` does not exist.
