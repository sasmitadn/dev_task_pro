# Database Schema

## Overview
Local SQLite database via `sqflite`. All IDs are UUID v4 strings.

---

## Tables

### `categories`
| Column  | Type    | Description                  |
|---------|---------|------------------------------|
| id      | TEXT PK | UUID                         |
| name    | TEXT    | Category label               |
| order   | INTEGER | Display order                |

**Seeded defaults:** Mobile, Web, Backend, Desktop

---

### `priorities`
| Column  | Type    | Description                  |
|---------|---------|------------------------------|
| id      | TEXT PK | UUID                         |
| name    | TEXT    | Priority label               |
| level   | INTEGER | Severity (1=Low … 4=Critical)|
| order   | INTEGER | Display order                |

**Seeded defaults:** Critical(4), High(3), Medium(2), Low(1)

---

### `projects`
| Column        | Type    | Description                         |
|---------------|---------|-------------------------------------|
| id            | TEXT PK | UUID                                |
| name          | TEXT    | Project name                        |
| status        | TEXT    | active / paused / completed         |
| priority_id   | TEXT FK | → priorities.id                     |
| category_id   | TEXT FK | → categories.id                     |
| description   | TEXT    | Short description                   |
| tech_stack    | TEXT    | Comma-separated tech names          |
| urls          | TEXT    | Newline-separated URLs              |
| due_date      | TEXT    | ISO 8601 date string                |
| system        | TEXT    | System design notes (markdown/text) |
| brainstorming | TEXT    | Brainstorm freeform notes           |
| order         | INTEGER | Display order                       |
| created_at    | TEXT    | ISO 8601 timestamp                  |
| updated_at    | TEXT    | ISO 8601 timestamp (auto-updated)   |

---

### `task_folders`
| Column       | Type    | Description                        |
|--------------|---------|------------------------------------|
| id           | TEXT PK | UUID                               |
| project_id   | TEXT FK | → projects.id (CASCADE DELETE)     |
| name         | TEXT    | Folder / group name                |
| is_completed | INTEGER | 0 or 1                             |
| order        | INTEGER | Display order                      |
| created_at   | TEXT    | ISO 8601 timestamp                 |

---

### `subtasks`
| Column         | Type    | Description                           |
|----------------|---------|---------------------------------------|
| id             | TEXT PK | UUID                                  |
| task_folder_id | TEXT FK | → task_folders.id (CASCADE DELETE)    |
| name           | TEXT    | Subtask description                   |
| is_completed   | INTEGER | 0 or 1                                |
| order          | INTEGER | Display order                         |
| created_at     | TEXT    | ISO 8601 timestamp                    |

---

### `timesheet_logs`
| Column         | Type    | Description                             |
|----------------|---------|-----------------------------------------|
| id             | TEXT PK | UUID                                    |
| project_id     | TEXT FK | → projects.id (CASCADE DELETE)          |
| task_folder_id | TEXT    | Optional: which task folder             |
| subtask_id     | TEXT    | Optional: which subtask                 |
| start_time     | TEXT    | ISO 8601 timestamp                      |
| end_time       | TEXT    | NULL if timer is still running          |
| note           | TEXT    | Session note entered on stop            |

**Running timer detection:** `WHERE end_time IS NULL LIMIT 1`

---

## Relationships

```
categories ──< projects >── priorities
projects ──< task_folders ──< subtasks
projects ──< timesheet_logs
```

## Export / Import Format

JSON object:
```json
{
  "version": 1,
  "exported_at": "<ISO timestamp>",
  "categories": [...],
  "priorities": [...],
  "projects": [...],
  "task_folders": [...],
  "subtasks": [...],
  "timesheet_logs": [...]
}
```

Import uses `INSERT OR REPLACE` (conflict resolution: newest overwrites on re-import).
