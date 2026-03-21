# Task Details - Comments Screen -> SQL Server Mapping

Based on the provided "Comments" tab screenshot in Task Details.

## Screen fields to table columns

### Comment list (author, date, text)
- Source table: `dbo.TblTrnTSKTaskComment`
- Mapped columns:
  - Comment text -> `CommentEn`, `CommentAr`
  - Comment date/time -> `CreatedOnUtc`
  - Edited flag/time -> `IsEdited`, `EditedOnUtc`
  - Author -> `CreatedByUserId` -> join `dbo.TblMstTSKUser`
    - display name from `FullNameEn/FullNameAr`
    - avatar initials derived in app layer from full name

### New comment input + send action
- Insert into: `dbo.TblTrnTSKTaskComment`
- Optional idempotency key for safe retries:
  - `ClientMessageRef` (unique per tenant+task while active)

### Autosave behavior ("Last saved automatically")
- Draft table: `dbo.TblTrnTSKTaskCommentDraft`
  - `DraftEn`, `DraftAr`
  - `LastAutoSavedOnUtc`
  - one active draft per `(TenantId, TaskId, UserId)`

### Mentions (for notifications/inbox)
- Mention table: `dbo.TblTrnTSKTaskCommentMention`
  - `TaskCommentId`, `MentionedUserId`, `IsRead`, `IsNotified`

## DB constraints aligned to comments UX
- `CK_TblTrnTSKTaskComment_TextRequired`:
  - at least one of `CommentEn` / `CommentAr` must contain text.
- `UX_TblTrnTSKTaskComment_ClientMessageRef`:
  - prevents duplicate comment posts on network retries.

## Performance indexes for comments tab
- `IX_TblTrnTSKTaskComment_Task_CreatedOn`
  - optimized for loading task comments newest first.
- `IX_TblTrnTSKTaskComment_Parent_CreatedOn`
  - supports threaded view expansion (scalable future-proofing).
- `IX_TblTrnTSKTaskCommentDraft_User_LastAutoSaved`
  - quick draft retrieval per user.
- `IX_TblTrnTSKTaskCommentMention_User_Inbox`
  - mention notification inbox lookups.
