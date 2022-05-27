CREATE SCHEMA IF NOT EXISTS pgtrail;
CREATE TABLE pgtrail.audit_changes
(
    id           uuid     NOT NULL,
    operation    TEXT     NOT NULL,
    object_id    uuid     NOT NULL,
    object_table regclass NOT NULL,
    created_at   timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    db_user      TEXT NULL,
    "before"     jsonb NULL,
    "after"      jsonb NULL,

    CONSTRAINT audit_changes_pkey PRIMARY KEY (id)
);
CREATE INDEX audit_changes_created_at_index ON pgtrail.audit_changes USING brin (created_at);
CREATE INDEX audit_changes_object_id_index ON pgtrail.audit_changes USING btree (object_id);
