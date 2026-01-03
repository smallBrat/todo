BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "daily_summary" (
    "id" bigserial PRIMARY KEY,
    "date" timestamp without time zone NOT NULL,
    "completedTasks" bigint NOT NULL,
    "missedTasks" bigint NOT NULL,
    "insights" text
);

-- Indexes
CREATE UNIQUE INDEX "daily_summary_date_idx" ON "daily_summary" USING btree ("date");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "goal" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "title" text NOT NULL,
    "priority" text NOT NULL,
    "date" timestamp without time zone NOT NULL,
    "status" text NOT NULL
);

-- Indexes
CREATE INDEX "goal_userId_idx" ON "goal" USING btree ("userId");
CREATE INDEX "goal_date_idx" ON "goal" USING btree ("date");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "task" (
    "id" bigserial PRIMARY KEY,
    "goalId" bigint NOT NULL,
    "title" text NOT NULL,
    "estimatedDuration" bigint NOT NULL,
    "energyLevel" text NOT NULL,
    "priority" text NOT NULL,
    "scheduledTime" timestamp without time zone,
    "status" text NOT NULL
);

-- Indexes
CREATE INDEX "task_goalId_idx" ON "task" USING btree ("goalId");
CREATE INDEX "task_scheduledTime_idx" ON "task" USING btree ("scheduledTime");


--
-- MIGRATION VERSION FOR daily_productivity_assistant
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('daily_productivity_assistant', '20251217025232741', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251217025232741', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
