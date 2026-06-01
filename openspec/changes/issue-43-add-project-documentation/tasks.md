# Tasks: Issue #43

## Directory Setup
- [ ] Create `docs/` directory at repository root
- [ ] Create `docs/add/` directory for Architectural Design Decisions

## ADD Documents
- [ ] Write `docs/add/README.md` — index of all ADDs with title, status, and one-line summary
- [ ] Write `docs/add/add-001-godot4-migration.md` — document the Godot 3 to Godot 4 migration decision with context, alternatives, and consequences
- [ ] Write `docs/add/add-002-generic-behaviour-scripts.md` — document the generic base-script architecture pattern with context, alternatives, and consequences
- [ ] Write `docs/add/add-003-multi-character-design.md` — document the multi-character World_Scene controller design with context, alternatives, and consequences
- [ ] Write `docs/add/add-004-gut-testing-approach.md` — document the GUT testing framework choice and CI configuration with context, alternatives, and consequences

## Existing Documentation Updates
- [ ] Update `README.md` — add a "Documentation" section linking to `docs/add/` and describing the ADD convention
- [ ] Update `CHANGELOG.md` — add cross-references to relevant ADD documents under version entries (0.2 migration entry -> ADD-001)
- [ ] Update `.github/copilot-instructions.md` — add a "Documentation" subsection under "Repository Structure" describing `docs/add/` and the ADD convention

## Validation
- [ ] Verify all ADD files follow a consistent structure: Status, Context, Decision, Alternatives Considered, Consequences
- [ ] Verify `docs/add/README.md` index accurately lists all ADD documents
- [ ] Verify all cross-references in README.md, CHANGELOG.md, and copilot-instructions.md point to valid file paths under `docs/add/`
