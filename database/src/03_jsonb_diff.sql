CREATE OR REPLACE FUNCTION jsonb_diff(a jsonb, b jsonb)
RETURNS jsonb AS $$
BEGIN
    RETURN (
        SELECT jsonb_object_agg(key, value_a)
        FROM (
            SELECT key, a -> key AS value_a
            FROM jsonb_each(a)
            WHERE a -> key IS DISTINCT FROM b -> key
        ) AS diff
    );
END;
$$ LANGUAGE plpgsql
;
