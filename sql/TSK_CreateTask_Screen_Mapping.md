# Create Task Screen -> SQL Server Table Mapping

Based on the two provided "Create new task" screens.

## ID standard
- All primary key columns use **table-wise `BIGINT IDENTITY(1,1)`**.
- Foreign key columns use `BIGINT` to match parent keys.

## Required fields
- `Task name *` -> `dbo.TblTrnTSKTask.TaskTitleEn` (and optional `TaskTitleAr`)
- `Due date *` -> `dbo.TblTrnTSKTask.DueUtc` (**NOT NULL**)

## Header fields
- `Task name` -> `TblTrnTSKTask.TaskTitleEn/TaskTitleAr`
- `Due date` -> `TblTrnTSKTask.DueUtc`
- `Priority` -> `TblTrnTSKTask.PriorityId` -> FK `TblMstTSKPriority`
- `Description` -> `TblTrnTSKTask.TaskDescriptionEn/TaskDescriptionAr`
- `Portfolio` dropdown -> `TblTrnTSKTask.ProjectId` -> FK `TblMstTSKProject`
- `Team` dropdown -> `TblTrnTSKTask.TeamId` -> FK `TblMstTSKTeam`

## Team/member picker with workload %
- Team master -> `dbo.TblMstTSKTeam`
- Team members -> `dbo.TblMstTSKTeamMember`
- User details -> `dbo.TblMstTSKUser` (`FullNameEn/Ar`, `JobTitleEn/Ar`)
- Workload percentage/status -> `dbo.TblTrnTSKMemberKpiSnapshot` (latest snapshot)
- Selected assignees -> `dbo.TblTrnTSKTaskAssignment`

## Subtasks
- Subtask input/list -> `dbo.TblTrnTSKTaskSubtask`
  - `SubtaskTitleEn/SubtaskTitleAr`
  - `DisplayOrder`
  - `IsCompleted`

## Attachments
- File upload -> `dbo.TblTrnTSKTaskAttachment`
- Validations in DB:
  - Max size 10MB (`CK_TblTrnTSKTaskAttachment_FileSize`)
  - Allowed extensions (`SVG/JPG/JPEG/PNG/PDF/DOC`) via `CK_TblTrnTSKTaskAttachment_FileExtension`

## Related behavior supported by schema
- Archive instead of delete:
  - `TblTrnTSKTask.IsArchived`, `ArchivedOnUtc`, `ArchivedByUserUo`, reason columns.
- Reassign task:
  - `TblTrnTSKTaskReassignment` + latest assignments in `TblTrnTSKTaskAssignment`.
- Activity feed updates:
  - `TblTrnTSKActivityFeed`.

## Query notes (high performance)
- Task board/filtering: `IX_TblTrnTSKTask_BoardLane`, `IX_TblTrnTSKTask_Team_Due`
- Assignee lookups: `IX_TblTrnTSKTaskAssignment_Assignee`
- Team members lookup: `IX_TblMstTSKTeamMember_Team`
