BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "daily_summary" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "daily_summary" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "date" timestamp without time zone NOT NULL,
    "totalTasksPlanned" bigint NOT NULL,
    "completedCount" bigint NOT NULL,
    "skippedCount" bigint NOT NULL,
    "missedCount" bigint NOT NULL,
    "completionRatio" double precision NOT NULL,
    "totalFocusedMinutes" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "daily_summary_user_date_idx" ON "daily_summary" USING btree ("userId", "date");


--
-- MIGRATION VERSION FOR daily_productivity_assistant
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('daily_productivity_assistant', '20251220032731145', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251220032731145', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
