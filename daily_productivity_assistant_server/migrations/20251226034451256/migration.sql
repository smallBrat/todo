BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "task" ADD COLUMN "deadline" timestamp without time zone;
CREATE INDEX "task_deadline_idx" ON "task" USING btree ("deadline");

--
-- MIGRATION VERSION FOR daily_productivity_assistant
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('daily_productivity_assistant', '20251226034451256', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251226034451256', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
