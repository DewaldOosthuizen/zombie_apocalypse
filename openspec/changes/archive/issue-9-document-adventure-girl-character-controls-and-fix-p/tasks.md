# Tasks — Issue #9
# Document Adventure Girl character controls and fix project name mismatch


## A. project.godot — Fix config/name

- [ ] A1. Open project.godot.
- [ ] A2. On line 18, change `config/name="Retro_Apocalyse"` to `config/name="Zombie Apocalypse"`.
- [ ] A3. Launch the game in the Godot editor and confirm the OS window title bar
         now reads "Zombie Apocalypse".
- [ ] A4. Verify no other line in project.godot references "Retro_Apocalyse" or
         "Retro_Apocalypse".


## B. README.md — Add Adventure Girl section

- [ ] B1. After the MALE NINJA CONTROLS section (after line 41), insert the
         ADVENTURE GIRL CONTROLS block as specified in proposal.md Fix 2.
- [ ] B2. Ensure the WIP status notice is present and clearly states that no
         playable scene exists yet.
- [ ] B3. Confirm the key bindings listed (A/D/W/SPACE/ARROW keys, CTRL, Z, X)
         match the input map entries in project.godot (move_left, move_right,
         move_jump, action_1, action_2, action_3).


## C. README.md — Add Characters overview table

- [ ] C1. Insert the ## Characters section as specified in proposal.md Fix 2.
- [ ] C2. Verify the table accurately reflects the three known characters:
         Robot (playable), Male Ninja (playable), Adventure Girl (WIP).
- [ ] C3. Confirm the "Animations available" column for Adventure Girl lists all
         sprite animation folders present in
         resources/characters/adventure_girl/png/:
         Idle, Dead, Jump, Melee, Run, Shoot, Slide.
- [ ] C4. Review resources/characters/ for any additional character directories
         not yet documented and add them to the table if found.


## D. CHANGELOG.md — Replace plugin boilerplate with project history

- [ ] D1. Remove the existing content (lines 1–21), which is unrelated plugin
         boilerplate copied from GUT or another addon.
- [ ] D2. Replace with the Zombie Apocalypse-specific changelog as specified in
         proposal.md Fix 3, using "Zombie Apocalypse" as the project name
         throughout.
- [ ] D3. Confirm the "Unreleased" section includes entries for the changes made
         in this issue (project name fix, Adventure Girl docs).
- [ ] D4. Confirm no reference to "Retro_Apocalyse" or "Retro_Apocalypse" appears
         anywhere in CHANGELOG.md.


## E. Cross-file consistency check

- [ ] E1. Search the entire repository for the string "Retro_Apocalyse" and
         confirm zero matches remain after the fix.
- [ ] E2. Search for "Retro_Apocalypse" (correctly spelled variant) and confirm
         it does not appear in any user-facing file (README, CHANGELOG, project.godot).
- [ ] E3. Verify README.md H1 heading ("# Zombie Apocalypse") and project.godot
         config/name ("Zombie Apocalypse") are identical after changes.


## F. PR review checklist

- [ ] F1. Open a PR targeting the default branch with title:
         "docs: fix project name typo and document Adventure Girl controls (#9)"
- [ ] F2. PR description references issue #9 and lists all three files changed.
- [ ] F3. Reviewer confirms no remaining name inconsistencies across README,
         CHANGELOG, and project.godot.
- [ ] F4. Reviewer confirms Adventure Girl section includes WIP notice and
         correct key bindings.
- [ ] F5. Reviewer confirms Characters table is present and accurate.
- [ ] F6. Merge and close issue #9.
