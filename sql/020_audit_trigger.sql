CREATE OR REPLACE FUNCTION pgtrail.audit_trigger()
    RETURNS trigger
    LANGUAGE plpgsql
AS
$$
declare
    object_id_column   TEXT = 'id';
    object_id_new      UUID;
    object_id_old      UUID;
    storage_table_name TEXT = 'pgtrail.audit_changes';
    new_jsonb          JSONB;
    new_old_difference JSONB;
    old_new_difference JSONB;

begin
    IF TG_NARGS > 0
    THEN
        object_id_column := TG_ARGV[0];
    END IF;

    IF TG_NARGS > 1
    THEN
        storage_table_name := TG_ARGV[1];
    END IF;

    object_id_new := (row_to_json(NEW) ->> object_id_column)::UUID;
    object_id_old := (row_to_json(OLD) ->> object_id_column)::UUID;

    IF TG_OP = 'INSERT'
    THEN
        new_jsonb := to_jsonb(NEW);

        execute format('INSERT INTO %s (id, operation, object_id, object_table, created_at, db_user, before, after)
        VALUES (gen_random_uuid(), ''%s'', ''%s'', ''%s'', now(), current_user, NULL,''%s''::jsonb);',
                       storage_table_name, TG_OP, object_id_new, TG_TABLE_NAME::regclass, new_jsonb);

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE'
    THEN
        IF NEW != OLD THEN
            new_old_difference = pgtrail.jsonb_diff(to_jsonb(NEW), to_jsonb(OLD));
            old_new_difference = pgtrail.jsonb_diff(to_jsonb(OLD), to_jsonb(NEW));

            execute format('INSERT INTO %s (id, operation, object_id, object_table, created_at, db_user, before, after)
            VALUES (gen_random_uuid(), ''%s'', ''%s'', ''%s'', now(), current_user, ''%s''::jsonb,''%s''::jsonb);',
                           storage_table_name, TG_OP, object_id_new, TG_TABLE_NAME::regclass, old_new_difference,
                           new_old_difference);
        END IF;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE'
    THEN
        execute format('INSERT INTO %s (id, operation, object_id, object_table, created_at, db_user, before, after)
            VALUES (gen_random_uuid(), ''%s'', ''%s'', ''%s'', now(), current_user, NULL,NULL);',
                       storage_table_name, TG_OP, object_id_old, TG_TABLE_NAME::regclass);

        RETURN OLD;
    END IF;
end;
$$;


CREATE OR REPLACE FUNCTION pgtrail.enable_audit(target_table REGCLASS, object_id_column TEXT DEFAULT 'id',
                                                storage_table REGCLASS DEFAULT 'pgtrail.audit_changes'::regclass)
    RETURNS VOID
    VOLATILE
    LANGUAGE plpgsql
AS
$$

begin
    execute format('
	DROP TRIGGER IF EXISTS pgtrail_audit_trigger ON %s;
    CREATE TRIGGER pgtrail_audit_trigger
    BEFORE INSERT OR UPDATE OR DELETE
    ON %s FOR EACH ROW EXECUTE PROCEDURE pgtrail.audit_trigger(''%s'', ''%s'');', target_table, target_table,
                   object_id_column, storage_table);
end;
$$;


CREATE OR REPLACE FUNCTION pgtrail.disable_audit(target_table regclass)
    RETURNS VOID
    VOLATILE
    LANGUAGE plpgsql
AS
$$
begin
    execute format('DROP TRIGGER IF EXISTS pgtrail_audit_trigger ON %s;', target_table);
end;
$$;
