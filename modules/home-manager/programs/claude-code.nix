{ pkgs, config, ... }:

let
  ralphLoopScriptsDir = "${config.home.homeDirectory}/.claude/scripts/ralph-loop";
in
{
  programs.claude-code = {
    enable = true;

    settings = {
      includeCoAuthoredBy = false;
      model = "opus";
      alwaysThinkingEnabled = true;
      statusLine = {
        type = "command";
        command = "bun x ccusage statusline";
      };
      hooks = {
        Stop = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "${ralphLoopScriptsDir}/stop-hook.sh";
              }
            ];
          }
        ];
      };
    };

    agents = {
      "code-simplifier.md" = ''
        ---
        name: code-simplifier
        description: Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code unless instructed otherwise.
        model: opus
        ---

        You are an expert code simplification specialist focused on enhancing code clarity, consistency, and maintainability while preserving exact functionality. Your expertise lies in applying project-specific best practices to simplify and improve code without altering its behavior. You prioritize readable, explicit code over overly compact solutions. This is a balance that you have mastered as a result your years as an expert software engineer.

        You will analyze recently modified code and apply refinements that:

        1. **Preserve Functionality**: Never change what the code does - only how it does it. All original features, outputs, and behaviors must remain intact.

        2. **Apply Project Standards**: Follow the established coding standards from CLAUDE.md including:

           - Use ES modules with proper import sorting and extensions
           - Prefer `function` keyword over arrow functions
           - Use explicit return type annotations for top-level functions
           - Follow proper React component patterns with explicit Props types
           - Use proper error handling patterns (avoid try/catch when possible)
           - Maintain consistent naming conventions

        3. **Enhance Clarity**: Simplify code structure by:

           - Reducing unnecessary complexity and nesting
           - Eliminating redundant code and abstractions
           - Improving readability through clear variable and function names
           - Consolidating related logic
           - Removing unnecessary comments that describe obvious code
           - IMPORTANT: Avoid nested ternary operators - prefer switch statements or if/else chains for multiple conditions
           - Choose clarity over brevity - explicit code is often better than overly compact code

        4. **Maintain Balance**: Avoid over-simplification that could:

           - Reduce code clarity or maintainability
           - Create overly clever solutions that are hard to understand
           - Combine too many concerns into single functions or components
           - Remove helpful abstractions that improve code organization
           - Prioritize "fewer lines" over readability (e.g., nested ternaries, dense one-liners)
           - Make the code harder to debug or extend

        5. **Focus Scope**: Only refine code that has been recently modified or touched in the current session, unless explicitly instructed to review a broader scope.

        Your refinement process:

        1. Identify the recently modified code sections
        2. Analyze for opportunities to improve elegance and consistency
        3. Apply project-specific best practices and coding standards
        4. Ensure all functionality remains unchanged
        5. Verify the refined code is simpler and more maintainable
        6. Document only significant changes that affect understanding

        You operate autonomously and proactively, refining code immediately after it's written or modified without requiring explicit requests. Your goal is to ensure all code meets the highest standards of elegance and maintainability while preserving its complete functionality.
      '';
    };

    skills = {
      "prd/SKILL" = ''
        ---
        name: prd
        description: "Generate a Product Requirements Document (PRD) for a new feature. Use when planning a feature, starting a new project, or when asked to create a PRD. Triggers on: create a prd, write prd for, plan this feature, requirements for, spec out."
        ---

        # PRD Generator

        Create detailed Product Requirements Documents that are clear, actionable, and suitable for implementation.

        ---

        ## The Job

        1. Receive a feature description from the user
        2. Ask 3-5 essential clarifying questions (with lettered options)
        3. Generate a structured PRD based on answers
        4. Save to `tasks/prd-[feature-name].md`

        **Important:** Do NOT start implementing. Just create the PRD.

        ---

        ## Step 1: Clarifying Questions

        Ask only critical questions where the initial prompt is ambiguous. Focus on:

        - **Problem/Goal:** What problem does this solve?
        - **Core Functionality:** What are the key actions?
        - **Scope/Boundaries:** What should it NOT do?
        - **Success Criteria:** How do we know it's done?

        ### Format Questions Like This:

        ```
        1. What is the primary goal of this feature?
           A. Improve user onboarding experience
           B. Increase user retention
           C. Reduce support burden
           D. Other: [please specify]

        2. Who is the target user?
           A. New users only
           B. Existing users only
           C. All users
           D. Admin users only

        3. What is the scope?
           A. Minimal viable version
           B. Full-featured implementation
           C. Just the backend/API
           D. Just the UI
        ```

        This lets users respond with "1A, 2C, 3B" for quick iteration.

        ---

        ## Step 2: PRD Structure

        Generate the PRD with these sections:

        ### 1. Introduction/Overview
        Brief description of the feature and the problem it solves.

        ### 2. Goals
        Specific, measurable objectives (bullet list).

        ### 3. User Stories
        Each story needs:
        - **Title:** Short descriptive name
        - **Description:** "As a [user], I want [feature] so that [benefit]"
        - **Acceptance Criteria:** Verifiable checklist of what "done" means

        Each story should be small enough to implement in one focused session.

        **Format:**
        ```markdown
        ### US-001: [Title]
        **Description:** As a [user], I want [feature] so that [benefit].

        **Acceptance Criteria:**
        - [ ] Specific verifiable criterion
        - [ ] Another criterion
        - [ ] Typecheck/lint passes
        - [ ] **[UI stories only]** Verify in browser using dev-browser skill
        ```

        **Important:**
        - Acceptance criteria must be verifiable, not vague. "Works correctly" is bad. "Button shows confirmation dialog before deleting" is good.
        - **For any story with UI changes:** Always include "Verify in browser using dev-browser skill" as acceptance criteria. This ensures visual verification of frontend work.

        ### 4. Functional Requirements
        Numbered list of specific functionalities:
        - "FR-1: The system must allow users to..."
        - "FR-2: When a user clicks X, the system must..."

        Be explicit and unambiguous.

        ### 5. Non-Goals (Out of Scope)
        What this feature will NOT include. Critical for managing scope.

        ### 6. Design Considerations (Optional)
        - UI/UX requirements
        - Link to mockups if available
        - Relevant existing components to reuse

        ### 7. Technical Considerations (Optional)
        - Known constraints or dependencies
        - Integration points with existing systems
        - Performance requirements

        ### 8. Success Metrics
        How will success be measured?
        - "Reduce time to complete X by 50%"
        - "Increase conversion rate by 10%"

        ### 9. Open Questions
        Remaining questions or areas needing clarification.

        ---

        ## Writing for Junior Developers

        The PRD reader may be a junior developer or AI agent. Therefore:

        - Be explicit and unambiguous
        - Avoid jargon or explain it
        - Provide enough detail to understand purpose and core logic
        - Number requirements for easy reference
        - Use concrete examples where helpful

        ---

        ## Output

        - **Format:** Markdown (`.md`)
        - **Location:** `tasks/`
        - **Filename:** `prd-[feature-name].md` (kebab-case)

        ---

        ## Example PRD

        ```markdown
        # PRD: Task Priority System

        ## Introduction

        Add priority levels to tasks so users can focus on what matters most. Tasks can be marked as high, medium, or low priority, with visual indicators and filtering to help users manage their workload effectively.

        ## Goals

        - Allow assigning priority (high/medium/low) to any task
        - Provide clear visual differentiation between priority levels
        - Enable filtering and sorting by priority
        - Default new tasks to medium priority

        ## User Stories

        ### US-001: Add priority field to database
        **Description:** As a developer, I need to store task priority so it persists across sessions.

        **Acceptance Criteria:**
        - [ ] Add priority column to tasks table: 'high' | 'medium' | 'low' (default 'medium')
        - [ ] Generate and run migration successfully
        - [ ] Typecheck passes

        ### US-002: Display priority indicator on task cards
        **Description:** As a user, I want to see task priority at a glance so I know what needs attention first.

        **Acceptance Criteria:**
        - [ ] Each task card shows colored priority badge (red=high, yellow=medium, gray=low)
        - [ ] Priority visible without hovering or clicking
        - [ ] Typecheck passes
        - [ ] Verify in browser using dev-browser skill

        ### US-003: Add priority selector to task edit
        **Description:** As a user, I want to change a task's priority when editing it.

        **Acceptance Criteria:**
        - [ ] Priority dropdown in task edit modal
        - [ ] Shows current priority as selected
        - [ ] Saves immediately on selection change
        - [ ] Typecheck passes
        - [ ] Verify in browser using dev-browser skill

        ### US-004: Filter tasks by priority
        **Description:** As a user, I want to filter the task list to see only high-priority items when I'm focused.

        **Acceptance Criteria:**
        - [ ] Filter dropdown with options: All | High | Medium | Low
        - [ ] Filter persists in URL params
        - [ ] Empty state message when no tasks match filter
        - [ ] Typecheck passes
        - [ ] Verify in browser using dev-browser skill

        ## Functional Requirements

        - FR-1: Add `priority` field to tasks table ('high' | 'medium' | 'low', default 'medium')
        - FR-2: Display colored priority badge on each task card
        - FR-3: Include priority selector in task edit modal
        - FR-4: Add priority filter dropdown to task list header
        - FR-5: Sort by priority within each status column (high to medium to low)

        ## Non-Goals

        - No priority-based notifications or reminders
        - No automatic priority assignment based on due date
        - No priority inheritance for subtasks

        ## Technical Considerations

        - Reuse existing badge component with color variants
        - Filter state managed via URL search params
        - Priority stored in database, not computed

        ## Success Metrics

        - Users can change priority in under 2 clicks
        - High-priority tasks immediately visible at top of lists
        - No regression in task list performance

        ## Open Questions

        - Should priority affect task ordering within a column?
        - Should we add keyboard shortcuts for priority changes?
        ```

        ---

        ## Checklist

        Before saving the PRD:

        - [ ] Asked clarifying questions with lettered options
        - [ ] Incorporated user's answers
        - [ ] User stories are small and specific
        - [ ] Functional requirements are numbered and unambiguous
        - [ ] Non-goals section defines clear boundaries
        - [ ] Saved to `tasks/prd-[feature-name].md`
      '';

      "ralph/SKILL" = ''
        ---
        name: ralph
        description: "Convert PRDs to prd.json format for the Ralph autonomous agent system. Use when you have an existing PRD and need to convert it to Ralph's JSON format. Triggers on: convert this prd, turn this into ralph format, create prd.json from this, ralph json."
        ---

        # Ralph PRD Converter

        Converts existing PRDs to the prd.json format that Ralph uses for autonomous execution.

        ---

        ## The Job

        Take a PRD (markdown file or text) and convert it to `prd.json` in your ralph directory.

        ---

        ## Output Format

        ```json
        {
          "project": "[Project Name]",
          "branchName": "ralph/[feature-name-kebab-case]",
          "description": "[Feature description from PRD title/intro]",
          "userStories": [
            {
              "id": "US-001",
              "title": "[Story title]",
              "description": "As a [user], I want [feature] so that [benefit]",
              "acceptanceCriteria": [
                "Criterion 1",
                "Criterion 2",
                "Typecheck passes"
              ],
              "priority": 1,
              "passes": false,
              "notes": ""
            }
          ]
        }
        ```

        ---

        ## Story Size: The Number One Rule

        **Each story must be completable in ONE Ralph iteration (one context window).**

        Ralph spawns a fresh Amp instance per iteration with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

        ### Right-sized stories:
        - Add a database column and migration
        - Add a UI component to an existing page
        - Update a server action with new logic
        - Add a filter dropdown to a list

        ### Too big (split these):
        - "Build the entire dashboard" - Split into: schema, queries, UI components, filters
        - "Add authentication" - Split into: schema, middleware, login UI, session handling
        - "Refactor the API" - Split into one story per endpoint or pattern

        **Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

        ---

        ## Story Ordering: Dependencies First

        Stories execute in priority order. Earlier stories must not depend on later ones.

        **Correct order:**
        1. Schema/database changes (migrations)
        2. Server actions / backend logic
        3. UI components that use the backend
        4. Dashboard/summary views that aggregate data

        **Wrong order:**
        1. UI component (depends on schema that does not exist yet)
        2. Schema change

        ---

        ## Acceptance Criteria: Must Be Verifiable

        Each criterion must be something Ralph can CHECK, not something vague.

        ### Good criteria (verifiable):
        - "Add `status` column to tasks table with default 'pending'"
        - "Filter dropdown has options: All, Active, Completed"
        - "Clicking delete shows confirmation dialog"
        - "Typecheck passes"
        - "Tests pass"

        ### Bad criteria (vague):
        - "Works correctly"
        - "User can do X easily"
        - "Good UX"
        - "Handles edge cases"

        ### Always include as final criterion:
        ```
        "Typecheck passes"
        ```

        For stories with testable logic, also include:
        ```
        "Tests pass"
        ```

        ### For stories that change UI, also include:
        ```
        "Verify in browser using dev-browser skill"
        ```

        Frontend stories are NOT complete until visually verified. Ralph will use the dev-browser skill to navigate to the page, interact with the UI, and confirm changes work.

        ---

        ## Conversion Rules

        1. **Each user story becomes one JSON entry**
        2. **IDs**: Sequential (US-001, US-002, etc.)
        3. **Priority**: Based on dependency order, then document order
        4. **All stories**: `passes: false` and empty `notes`
        5. **branchName**: Derive from feature name, kebab-case, prefixed with `ralph/`
        6. **Always add**: "Typecheck passes" to every story's acceptance criteria

        ---

        ## Splitting Large PRDs

        If a PRD has big features, split them:

        **Original:**
        > "Add user notification system"

        **Split into:**
        1. US-001: Add notifications table to database
        2. US-002: Create notification service for sending notifications
        3. US-003: Add notification bell icon to header
        4. US-004: Create notification dropdown panel
        5. US-005: Add mark-as-read functionality
        6. US-006: Add notification preferences page

        Each is one focused change that can be completed and verified independently.

        ---

        ## Example

        **Input PRD:**
        ```markdown
        # Task Status Feature

        Add ability to mark tasks with different statuses.

        ## Requirements
        - Toggle between pending/in-progress/done on task list
        - Filter list by status
        - Show status badge on each task
        - Persist status in database
        ```

        **Output prd.json:**
        ```json
        {
          "project": "TaskApp",
          "branchName": "ralph/task-status",
          "description": "Task Status Feature - Track task progress with status indicators",
          "userStories": [
            {
              "id": "US-001",
              "title": "Add status field to tasks table",
              "description": "As a developer, I need to store task status in the database.",
              "acceptanceCriteria": [
                "Add status column: 'pending' | 'in_progress' | 'done' (default 'pending')",
                "Generate and run migration successfully",
                "Typecheck passes"
              ],
              "priority": 1,
              "passes": false,
              "notes": ""
            },
            {
              "id": "US-002",
              "title": "Display status badge on task cards",
              "description": "As a user, I want to see task status at a glance.",
              "acceptanceCriteria": [
                "Each task card shows colored status badge",
                "Badge colors: gray=pending, blue=in_progress, green=done",
                "Typecheck passes",
                "Verify in browser using dev-browser skill"
              ],
              "priority": 2,
              "passes": false,
              "notes": ""
            },
            {
              "id": "US-003",
              "title": "Add status toggle to task list rows",
              "description": "As a user, I want to change task status directly from the list.",
              "acceptanceCriteria": [
                "Each row has status dropdown or toggle",
                "Changing status saves immediately",
                "UI updates without page refresh",
                "Typecheck passes",
                "Verify in browser using dev-browser skill"
              ],
              "priority": 3,
              "passes": false,
              "notes": ""
            },
            {
              "id": "US-004",
              "title": "Filter tasks by status",
              "description": "As a user, I want to filter the list to see only certain statuses.",
              "acceptanceCriteria": [
                "Filter dropdown: All | Pending | In Progress | Done",
                "Filter persists in URL params",
                "Typecheck passes",
                "Verify in browser using dev-browser skill"
              ],
              "priority": 4,
              "passes": false,
              "notes": ""
            }
          ]
        }
        ```

        ---

        ## Archiving Previous Runs

        **Before writing a new prd.json, check if there is an existing one from a different feature:**

        1. Read the current `prd.json` if it exists
        2. Check if `branchName` differs from the new feature's branch name
        3. If different AND `progress.txt` has content beyond the header:
           - Create archive folder: `archive/YYYY-MM-DD-feature-name/`
           - Copy current `prd.json` and `progress.txt` to archive
           - Reset `progress.txt` with fresh header

        **The ralph.sh script handles this automatically** when you run it, but if you are manually updating prd.json between runs, archive first.

        ---

        ## Checklist Before Saving

        Before writing prd.json, verify:

        - [ ] **Previous run archived** (if prd.json exists with different branchName, archive it first)
        - [ ] Each story is completable in one iteration (small enough)
        - [ ] Stories are ordered by dependency (schema to backend to UI)
        - [ ] Every story has "Typecheck passes" as criterion
        - [ ] UI stories have "Verify in browser using dev-browser skill" as criterion
        - [ ] Acceptance criteria are verifiable (not vague)
        - [ ] No story depends on a later story
      '';

      "ralph-loop/SKILL" = ''
        ---
        name: ralph-loop
        description: "Start Ralph Loop - an iterative self-referential development loop. Use when you need autonomous iteration on a task. Triggers on: start ralph loop, ralph loop, autonomous iteration."
        argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
        ---

        # Ralph Loop Command

        Execute the setup script to initialize the Ralph loop:

        ```!
        "${ralphLoopScriptsDir}/setup-ralph-loop.sh" $ARGUMENTS
        ```

        Please work on the task. When you try to exit, the Ralph loop will feed the SAME PROMPT back to you for the next iteration. You'll see your previous work in files and git history, allowing you to iterate and improve.

        CRITICAL RULE: If a completion promise is set, you may ONLY output it when the statement is completely and unequivocally TRUE. Do not output false promises to escape the loop, even if you think you're stuck or should exit for other reasons. The loop is designed to continue until genuine completion.
      '';

      "cancel-ralph/SKILL" = ''
        ---
        name: cancel-ralph
        description: "Cancel active Ralph Loop. Use when you need to stop a running ralph loop. Triggers on: cancel ralph, stop ralph, cancel loop."
        ---

        # Cancel Ralph

        To cancel the Ralph loop:

        1. Check if `.claude/ralph-loop.local.md` exists using Bash: `test -f .claude/ralph-loop.local.md && echo "EXISTS" || echo "NOT_FOUND"`

        2. **If NOT_FOUND**: Say "No active Ralph loop found."

        3. **If EXISTS**:
           - Read `.claude/ralph-loop.local.md` to get the current iteration number from the `iteration:` field
           - Remove the file using Bash: `rm .claude/ralph-loop.local.md`
           - Report: "Cancelled Ralph loop (was at iteration N)" where N is the iteration value
      '';

      "frontend-design/SKILL" = ''
        ---
        name: frontend-design
        description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
        license: Complete terms in LICENSE.txt
        ---

        This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

        The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

        ## Design Thinking

        Before coding, understand the context and commit to a BOLD aesthetic direction:
        - **Purpose**: What problem does this interface solve? Who uses it?
        - **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
        - **Constraints**: Technical requirements (framework, performance, accessibility).
        - **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

        **CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

        Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
        - Production-grade and functional
        - Visually striking and memorable
        - Cohesive with a clear aesthetic point-of-view
        - Meticulously refined in every detail

        ## Frontend Aesthetics Guidelines

        Focus on:
        - **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.
        - **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
        - **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.
        - **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
        - **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

        NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

        Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

        **IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

        Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.
      '';
    };
  };

  # Ralph Loop scripts
  home.file.".claude/scripts/ralph-loop/setup-ralph-loop.sh" = {
    executable = true;
    text = ''
#!/bin/bash

# Ralph Loop Setup Script
# Creates state file for in-session Ralph loop

set -euo pipefail

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"

# Parse options and positional arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Ralph Loop - Interactive self-referential development loop

USAGE:
  /ralph-loop [PROMPT...] [OPTIONS]

ARGUMENTS:
  PROMPT...    Initial prompt to start the loop (can be multiple words without quotes)

OPTIONS:
  --max-iterations <n>           Maximum iterations before auto-stop (default: unlimited)
  --completion-promise '<text>'  Promise phrase (USE QUOTES for multi-word)
  -h, --help                     Show this help message

DESCRIPTION:
  Starts a Ralph Loop in your CURRENT session. The stop hook prevents
  exit and feeds your output back as input until completion or iteration limit.

  To signal completion, you must output: <promise>YOUR_PHRASE</promise>

  Use this for:
  - Interactive iteration where you want to see progress
  - Tasks requiring self-correction and refinement
  - Learning how Ralph works

EXAMPLES:
  /ralph-loop Build a todo API --completion-promise 'DONE' --max-iterations 20
  /ralph-loop --max-iterations 10 Fix the auth bug
  /ralph-loop Refactor cache layer  (runs forever)
  /ralph-loop --completion-promise 'TASK COMPLETE' Create a REST API

STOPPING:
  Only by reaching --max-iterations or detecting --completion-promise
  No manual stop - Ralph runs infinitely by default!

MONITORING:
  # View current iteration:
  grep '^iteration:' .claude/ralph-loop.local.md

  # View full state:
  head -10 .claude/ralph-loop.local.md
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "''${2:-}" ]]; then
        echo "❌ Error: --max-iterations requires a number argument" >&2
        echo "" >&2
        echo "   Valid examples:" >&2
        echo "     --max-iterations 10" >&2
        echo "     --max-iterations 50" >&2
        echo "     --max-iterations 0  (unlimited)" >&2
        echo "" >&2
        echo "   You provided: --max-iterations (with no number)" >&2
        exit 1
      fi
      if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: --max-iterations must be a positive integer or 0, got: $2" >&2
        echo "" >&2
        echo "   Valid examples:" >&2
        echo "     --max-iterations 10" >&2
        echo "     --max-iterations 50" >&2
        echo "     --max-iterations 0  (unlimited)" >&2
        echo "" >&2
        echo "   Invalid: decimals (10.5), negative numbers (-5), text" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "''${2:-}" ]]; then
        echo "❌ Error: --completion-promise requires a text argument" >&2
        echo "" >&2
        echo "   Valid examples:" >&2
        echo "     --completion-promise 'DONE'" >&2
        echo "     --completion-promise 'TASK COMPLETE'" >&2
        echo "     --completion-promise 'All tests passing'" >&2
        echo "" >&2
        echo "   You provided: --completion-promise (with no text)" >&2
        echo "" >&2
        echo "   Note: Multi-word promises must be quoted!" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    *)
      # Non-option argument - collect all as prompt parts
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Join all prompt parts with spaces
PROMPT="''${PROMPT_PARTS[*]}"

# Validate prompt is non-empty
if [[ -z "$PROMPT" ]]; then
  echo "❌ Error: No prompt provided" >&2
  echo "" >&2
  echo "   Ralph needs a task description to work on." >&2
  echo "" >&2
  echo "   Examples:" >&2
  echo "     /ralph-loop Build a REST API for todos" >&2
  echo "     /ralph-loop Fix the auth bug --max-iterations 20" >&2
  echo "     /ralph-loop --completion-promise 'DONE' Refactor code" >&2
  echo "" >&2
  echo "   For all options: /ralph-loop --help" >&2
  exit 1
fi

# Create state file for stop hook (markdown with YAML frontmatter)
mkdir -p .claude

# Quote completion promise for YAML if it contains special chars or is not null
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

cat > .claude/ralph-loop.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

# Output setup message
cat <<EOF
🔄 Ralph loop activated in this session!

Iteration: 1
Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
Completion promise: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "''${COMPLETION_PROMISE//\"/} (ONLY output when TRUE - do not lie!)"; else echo "none (runs forever)"; fi)

The stop hook is now active. When you try to exit, the SAME PROMPT will be
fed back to you. You'll see your previous work in files, creating a
self-referential loop where you iteratively improve on the same task.

To monitor: head -10 .claude/ralph-loop.local.md

⚠️  WARNING: This loop cannot be stopped manually! It will run infinitely
    unless you set --max-iterations or --completion-promise.

🔄
EOF

# Output the initial prompt if provided
if [[ -n "$PROMPT" ]]; then
  echo ""
  echo "$PROMPT"
fi

# Display completion promise requirements if set
if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "CRITICAL - Ralph Loop Completion Promise"
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  echo "To complete this loop, output this EXACT text:"
  echo "  <promise>$COMPLETION_PROMISE</promise>"
  echo ""
  echo "STRICT REQUIREMENTS (DO NOT VIOLATE):"
  echo "  ✓ Use <promise> XML tags EXACTLY as shown above"
  echo "  ✓ The statement MUST be completely and unequivocally TRUE"
  echo "  ✓ Do NOT output false statements to exit the loop"
  echo "  ✓ Do NOT lie even if you think you should exit"
  echo ""
  echo "IMPORTANT - Do not circumvent the loop:"
  echo "  Even if you believe you're stuck, the task is impossible,"
  echo "  or you've been running too long - you MUST NOT output a"
  echo "  false promise statement. The loop is designed to continue"
  echo "  until the promise is GENUINELY TRUE. Trust the process."
  echo ""
  echo "  If the loop should stop, the promise statement will become"
  echo "  true naturally. Do not force it by lying."
  echo "═══════════════════════════════════════════════════════════"
fi
    '';
  };

  home.file.".claude/scripts/ralph-loop/stop-hook.sh" = {
    executable = true;
    text = ''
#!/bin/bash

# Ralph Loop Stop Hook
# Prevents session exit when a ralph-loop is active
# Feeds Claude's output back as input to continue the loop

set -euo pipefail

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(cat)

# Check if ralph-loop is active
RALPH_STATE_FILE=".claude/ralph-loop.local.md"

if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  # No active loop - allow exit
  exit 0
fi

# Parse markdown frontmatter (YAML between ---) and extract values
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
# Extract completion_promise and strip surrounding quotes if present
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

# Validate numeric fields before arithmetic operations
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "⚠️  Ralph loop: State file corrupted" >&2
  echo "   File: $RALPH_STATE_FILE" >&2
  echo "   Problem: 'iteration' field is not a valid number (got: '$ITERATION')" >&2
  echo "" >&2
  echo "   This usually means the state file was manually edited or corrupted." >&2
  echo "   Ralph loop is stopping. Run /ralph-loop again to start fresh." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "⚠️  Ralph loop: State file corrupted" >&2
  echo "   File: $RALPH_STATE_FILE" >&2
  echo "   Problem: 'max_iterations' field is not a valid number (got: '$MAX_ITERATIONS')" >&2
  echo "" >&2
  echo "   This usually means the state file was manually edited or corrupted." >&2
  echo "   Ralph loop is stopping. Run /ralph-loop again to start fresh." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Check if max iterations reached
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "🛑 Ralph loop: Max iterations ($MAX_ITERATIONS) reached."
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "⚠️  Ralph loop: Transcript file not found" >&2
  echo "   Expected: $TRANSCRIPT_PATH" >&2
  echo "   This is unusual and may indicate a Claude Code internal issue." >&2
  echo "   Ralph loop is stopping." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Read last assistant message from transcript (JSONL format - one JSON per line)
# First check if there are any assistant messages
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "⚠️  Ralph loop: No assistant messages found in transcript" >&2
  echo "   Transcript: $TRANSCRIPT_PATH" >&2
  echo "   This is unusual and may indicate a transcript format issue" >&2
  echo "   Ralph loop is stopping." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Extract last assistant message with explicit error handling
LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
if [[ -z "$LAST_LINE" ]]; then
  echo "⚠️  Ralph loop: Failed to extract last assistant message" >&2
  echo "   Ralph loop is stopping." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Parse JSON with error handling
LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>&1)

# Check if jq succeeded
if [[ $? -ne 0 ]]; then
  echo "⚠️  Ralph loop: Failed to parse assistant message JSON" >&2
  echo "   Error: $LAST_OUTPUT" >&2
  echo "   This may indicate a transcript format issue" >&2
  echo "   Ralph loop is stopping." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "⚠️  Ralph loop: Assistant message contained no text content" >&2
  echo "   Ralph loop is stopping." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Check for completion promise (only if set)
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  # Extract text from <promise> tags using Perl for multiline support
  # -0777 slurps entire input, s flag makes . match newlines
  # .*? is non-greedy (takes FIRST tag), whitespace normalized
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

  # Use = for literal string comparison (not pattern matching)
  # == in [[ ]] does glob pattern matching which breaks with *, ?, [ characters
  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "✅ Ralph loop: Detected <promise>$COMPLETION_PROMISE</promise>"
    rm "$RALPH_STATE_FILE"
    exit 0
  fi
fi

# Not complete - continue loop with SAME PROMPT
NEXT_ITERATION=$((ITERATION + 1))

# Extract prompt (everything after the closing ---)
# Skip first --- line, skip until second --- line, then print everything after
# Use i>=2 instead of i==2 to handle --- in prompt content
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$RALPH_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "⚠️  Ralph loop: State file corrupted or incomplete" >&2
  echo "   File: $RALPH_STATE_FILE" >&2
  echo "   Problem: No prompt text found" >&2
  echo "" >&2
  echo "   This usually means:" >&2
  echo "     • State file was manually edited" >&2
  echo "     • File was corrupted during writing" >&2
  echo "" >&2
  echo "   Ralph loop is stopping. Run /ralph-loop again to start fresh." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Update iteration in frontmatter (portable across macOS and Linux)
# Create temp file, then atomically replace
TEMP_FILE="''${RALPH_STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$RALPH_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$RALPH_STATE_FILE"

# Build system message with iteration count and completion promise info
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="🔄 Ralph iteration $NEXT_ITERATION | To stop: output <promise>$COMPLETION_PROMISE</promise> (ONLY when statement is TRUE - do not lie to exit!)"
else
  SYSTEM_MSG="🔄 Ralph iteration $NEXT_ITERATION | No completion promise set - loop runs infinitely"
fi

# Output JSON to block the stop and feed prompt back
# The "reason" field contains the prompt that will be sent back to Claude
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

# Exit 0 for successful hook execution
exit 0
    '';
  };
}
