BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "task" ADD COLUMN "completedAt" timestamp without time zone;
ALTER TABLE "task" ADD COLUMN "updatedAt" timestamp without time zone;

--
-- MIGRATION VERSION FOR daily_productivity_assistant
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('daily_productivity_assistant', '20251218035924427', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251218035924427', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
