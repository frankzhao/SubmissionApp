Phase 1
- Add a marking scheme.
- This will be Ruby, I've decided.  It's a list of sections, each of which has a name, description, source, and maximum mark.
- Write the show function for this.
- To start with, just require JSON input.
- To decide on the submission's actual mark, the 

Phase 2
- Alter the peer review cycle model so that it has a "has_been_activated" bool column.
- Make a function, `filter_files`, which runs when the user submits a zipfile and filters the files according to the specific rules.
- Add a function `peer_review_cycle#activate`, which adds relevant submission view permissions. Have it call different actual functions according to its `distribution_scheme`.
- Add a form to CRUD peer review cycles. Nest them under assignments. Index them in the staff course view.
- Make "shut_off_submissions" work, by adding a check as to whether the user has actually commented on the assignment.
- Use the `whenever` gem to go through every minute or whatever and check whether any peer review cycles need to be activated. If so, run them.

Phase 3
- Remove all of the todos.