
DROP TYPE IF EXISTS osm_upgrade.pointsnap CASCADE;
CREATE TYPE osm_upgrade.pointsnap AS (
       point geometry,
       line  geometry,
       numline  integer,
       dist  FLOAT
);

CREATE OR REPLACE FUNCTION osm_upgrade.multiline_locate_point(amultils geometry,apoint
geometry)
  RETURNS geometry AS
$BODY$
DECLARE
    mindistance float8;
    nearestlinestring geometry;
    nearestpoint geometry;
    i integer;

BEGIN
    mindistance := (distance(apoint,amultils)+100);
    IF NumGeometries(amultils) IS NULL THEN
         mindistance:=distance(apoint,amultils);
         nearestlinestring:=amultils;
    ELSE
         FOR i IN 1 .. NumGeometries(amultils) LOOP
             IF distance(apoint,GeometryN(amultils,i)) < mindistance THEN
                mindistance:=distance(apoint,GeometryN(amultils,i));
                nearestlinestring:=GeometryN(amultils,i);
             END IF
         END LOOP;
    END IF;

    nearestpoint:=line_interpolate_point(nearestlinestring,line_locate_point(nearestlinestring,apoint));
    RETURN nearestpoint;
END;
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE STRICT;
ALTER FUNCTION osm_upgrade.multiline_locate_point(amultils geometry,apoint geometry)
OWNER TO postgres;

--- find the point on a multilinestring nearest to the given point
--- returns the point, the (nearest) line, and the distance along the
--- linestring of the snap point
CREATE OR REPLACE FUNCTION osm_upgrade.multiline_locate_point_data(amultils geometry,apoint
geometry)
  RETURNS osm_upgrade.pointsnap AS
$BODY$
DECLARE
    mindistance float8;
    nearestlinestring geometry;
    nearestpoint geometry;
    nearestnumline integer;
    i integer;
    ret osm_upgrade.pointsnap;
    dist FLOAT;
BEGIN
    mindistance := (distance(apoint,amultils)+100);
    IF NumGeometries(amultils) IS NULL THEN
         mindistance:=distance(apoint,amultils);
         nearestlinestring:=amultils;
         nearestnumline:=0;
    ELSE
         FOR i IN 1 .. NumGeometries(amultils) LOOP
             IF distance(apoint,GeometryN(amultils,i)) < mindistance THEN
                mindistance:=distance(apoint,GeometryN(amultils,i));
                nearestlinestring:=GeometryN(amultils,i);
                nearestnumline:=i;
             END IF;
         END LOOP;
    END IF;

    dist := line_locate_point(nearestlinestring,apoint);
    nearestpoint:=line_interpolate_point(nearestlinestring,dist);

    ret.point=nearestpoint;
    ret.line = nearestlinestring;
    ret.dist = dist;
    ret.numline = nearestnumline;
    RETURN ret;
END;
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE STRICT;
ALTER FUNCTION osm_upgrade.multiline_locate_point_data(amultils geometry,apoint geometry)
OWNER TO postgres;
