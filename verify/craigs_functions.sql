-- Verify craigs_functions:craigs_functions on pg

BEGIN;

-- make sure functions don't puke

select tempseg.multiline_locate_point(
ST_GeomFromEWKT('SRID=4269;MULTILINESTRING((-117.9 33.5, -116.9 34.4))') ,
ST_GeomFromEWKT('SRID=4269;POINT(-117.8 33.5)') )
;

select tempseg.multiline_locate_point_data(
ST_GeomFromEWKT('SRID=4269;MULTILINESTRING((-117.9 33.5, -116.9 34.4))') ,
ST_GeomFromEWKT('SRID=4269;POINT(-117.8 33.5)') )
;


ROLLBACK;
