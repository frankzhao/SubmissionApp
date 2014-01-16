# Assignment
## Due date
### Turn off submissions?
If this is true, then the submission system closes after the due date. Otherwise, the system still highlights assignments which were handed in late.

## Marking scheme
Assignments are either marked with one mark, or with multiple seperate marks. Maximum marks are specified for either the assignment as a whole, or each section which is marked. It also includes a text field to describe the marking scheme.

## Submission format
### Plain text vs zipfile
If the assignment format is plain text, the user submits it in a HTML form. (I suppose I could let them submit it by file if they really wanted to for some reason.)
### Regex for filenames
For example, the assignment might only accept files ending in .hs. I could implement this filtering on the server, so students don't have to actually fix that themselves, the system would just clear it out for them.

## Behavior on submission
This is the behavior which is run when the assignment is submitted. It includes such things as:
- Compile it in GHC and comment on the assignment with the result of the compilation. (If the submission is a zipfile, it tries to compile Main.hs, but can be told to compile other files.)
- Alternatively, the system could refuse to accept the submission if it doesn't compile.
- Run it through a test spec and comment on the assignment with the results. This can also optionally mark the assignment.

## Peer review cycles
The convener can create arbitrary numbers of cycles of peer review, each of which has seperately chosen behavior. When you get access to someone's assignment, you can comment on it and submit changed versions of it.
### Distribution scheme
The review cycle can have multiple different distribution schemes. 
- Swap simultaneously: When this is activated, everyone who has submitted gets access to n other people's submission. 
- Send to previous submitter: Every submission is given to the previous student to submit. The first assignment is given to the student's tutor.
These will be implemented with the judicious use of helper methods, so it will be easy to write new, competing methods.
### Get marks
If this flag is true, then the peer reviewer gets to choose a mark. The peer review cycle would be connected to a section of the mark, as implemented in the marking scheme. The cycle has a field called *enabled_mark_sections* which tells it which mark sections the student gets to mark in.
### Shut off submissions
If this flag is true, then students cannot resubmit the assignment until they've provided their peer comments.
### Anonymise
If this flag is true, the students don't see each other's names.
