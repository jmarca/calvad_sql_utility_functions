-- Deploy craigs_functions:craigs_functions to pg

BEGIN;

CREATE TYPE tempseg.pointsnap AS (
       point geometry,
       line  geometry,
       numline  integer,
       dist  FLOAT
);

CREATE OR REPLACE FUNCTION tempseg.multiline_locate_point(amultils geometry,apoint
geometry)
  RETURNS geometry AS
$BODY$
DECLARE
    mindistance float8;
    nearestlinestring geometry;
    nearestpoint geometry;
    i integer;

BEGIN
    mindistance := (st_distance(apoint,amultils)+100);
    IF St_Numgeometries(amultils) IS NULL THEN
         mindistance:=st_distance(apoint,amultils);
         nearestlinestring:=amultils;
    ELSE
         FOR i IN 1 .. St_Numgeometries(amultils) LOOP
             IF st_distance(apoint,St_Geometryn(amultils,i)) < mindistance THEN
                mindistance:=st_distance(apoint,St_Geometryn(amultils,i));
                nearestlinestring:=St_Geometryn(amultils,i);
             END IF;
         END LOOP;
    END IF;

    nearestpoint:=st_lineinterpolatepoint(nearestlinestring,st_linelocatepoint(nearestlinestring,apoint));
    RETURN nearestpoint;
END;
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE STRICT;
ALTER FUNCTION tempseg.multiline_locate_point(amultils geometry,apoint geometry)
OWNER TO postgres;

--- find the point on a multilinestring nearest to the given point
--- returns the point, the (nearest) line, and the distance along the
--- linestring of the snap point
CREATE OR REPLACE FUNCTION tempseg.multiline_locate_point_data(amultils geometry,apoint
geometry)
  RETURNS tempseg.pointsnap AS
$BODY$
DECLARE
    mindistance float8;
    nearestlinestring geometry;
    nearestpoint geometry;
    nearestnumline integer;
    i integer;
    ret tempseg.pointsnap;
    dist FLOAT;
BEGIN
    mindistance := (st_distance(apoint,amultils)+100);
    IF St_Numgeometries(amultils) IS NULL THEN
         mindistance:=st_distance(apoint,amultils);
         nearestlinestring:=amultils;
         nearestnumline:=0;
    ELSE
         FOR i IN 1 .. St_Numgeometries(amultils) LOOP
             IF st_distance(apoint,St_Geometryn(amultils,i)) < mindistance THEN
                mindistance:=st_distance(apoint,St_Geometryn(amultils,i));
                nearestlinestring:=St_Geometryn(amultils,i);
                nearestnumline:=i;
             END IF;
         END LOOP;
    END IF;

    dist := st_linelocatepoint(nearestlinestring,apoint);
    nearestpoint:=st_lineinterpolatepoint(nearestlinestring,dist);

    ret.point=nearestpoint;
    ret.line = nearestlinestring;
    ret.dist = dist;
    ret.numline = nearestnumline;
    RETURN ret;
END;
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE STRICT;
ALTER FUNCTION tempseg.multiline_locate_point_data(amultils geometry,apoint geometry)
OWNER TO postgres;


COMMIT;
