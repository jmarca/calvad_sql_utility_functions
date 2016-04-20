-- Revert craigs_functions:craigs_functions from pg

BEGIN;

drop function tempseg.multiline_locate_point_data(geometry,geometry);
drop function tempseg.multiline_locate_point(geometry,geometry);
DROP TYPE IF EXISTS tempseg.pointsnap;

COMMIT;
