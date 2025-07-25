$ javac makepw.java
$ java makepw

use output for command later:

$ psql -U regapp-user -d regapp -h 127.0.0.1
UPDATE adminusertable
SET password = '{SHA-512/256|I6XoWZG8Je3IJ09ZA63DEdmU/5nhFkFmZAjo26U3dHg=|AAAAAAAAAAA=}',
    updated_at = NOW()
WHERE username = 'admin';

