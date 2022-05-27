CREATE OR REPLACE FUNCTION pgtrail.jsonb_diff("left" JSONB, "right" JSONB)
    RETURNS JSONB
    IMMUTABLE
AS
$$
SELECT jsonb_object_agg(a.key, a.value)
FROM (SELECT key, value FROM jsonb_each("left")) a
         LEFT OUTER JOIN
         (SELECT key, value FROM jsonb_each("right")) b ON a.key = b.key
WHERE a.value != b.value
   OR b.key IS NULL;
$$
    LANGUAGE sql;
