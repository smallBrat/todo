BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "daily_plan" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "date" timestamp without time zone NOT NULL,
    "totalTaskMinutes" bigint NOT NULL,
    "totalBreakMinutes" bigint NOT NULL,
    "freeMinutes" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "userId_date_idx" ON "daily_plan" USING btree ("userId", "date");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "daily_plan_slot" (
    "id" bigserial PRIMARY KEY,
    "planId" bigint NOT NULL,
    "startTime" timestamp without time zone NOT NULL,
    "endTime" timestamp without time zone NOT NULL,
    "durationMinutes" bigint NOT NULL,
    "type" text NOT NULL,
    "title" text NOT NULL,
    "taskId" bigint,
    "energyLevel" text,
    "priority" text
);

-- Indexes
CREATE INDEX "planId_idx" ON "daily_plan_slot" USING btree ("planId");


--
-- MIGRATION VERSION FOR daily_productivity_assistant
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('daily_productivity_assistant', '20251217102604125', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251217102604125', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
