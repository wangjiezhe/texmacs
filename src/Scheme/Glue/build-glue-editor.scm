
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : build-glue-editor.scm
;; DESCRIPTION : Building basic glue for the editor
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(output-copyright "build-glue-editor.scm")

(build
  "get_current_editor()->"
  "initialize_glue_editor"

  ;; important paths and trees
  (root-tree the_root (tree))
  (buffer-path the_buffer_path (path))
  (buffer-tree the_buffer (tree))
  (paragraph-tree the_line (tree))
  (cursor-path the_path (path))
  (cursor-path* the_shifted_path (path))
  (selection-tree selection_get (tree))

  ;; low-level modification routines
  (path->tree the_subtree (tree path))
  (path-correct-old correct (void path))
  (path-insert-with insert_with (void path string content))
  (path-remove-with remove_with (void path string))

  (position-new-path position_new (observer path))
  (position-delete position_delete (void observer))
  (position-set position_set (void observer path))
  (position-get position_get (path observer))

  ;; general modification routines
  (inside? inside (bool tree_label))
  (cpp-insert insert_tree (void content))
  (cpp-insert-go-to var_insert_tree (void content path))
  (insert-raw-go-to insert_tree (void content path))
  (insert-raw-return insert_return (void))
  (remove-text remove_text (void bool))
  (remove-structure remove_structure (void bool))
  (remove-structure-upwards remove_structure_upwards (void))

  (cpp-make make_compound (void tree_label))
  (cpp-make-arity make_compound (void tree_label int))
  (activate activate (void))
  (insert-argument insert_argument (void bool))
  (remove-argument remove_argument (void bool))
  (insert-argument-at insert_argument (void path bool))
  (remove-argument-at remove_argument (void path bool))
  (cpp-make-with make_with (void string string))
  (make-mod-active make_mod_active (void tree_label))
  (make-style-with make_style_with (void string string))
  (cpp-make-hybrid make_hybrid (void))
  (activate-latex activate_latex (void))
  (activate-hybrid activate_hybrid (void bool))
  (activate-symbol activate_symbol (void))
  (make-return-before make_return_before (void))
  (make-return-after make_return_after (bool))
  (temp-proof-fix temp_proof_fix (void))

  ;; document-wide modifications
  (get-full-env get_full_env (tree))
  (get-all-inits get_init_all (tree))
  (init-default-one init_default (void string))
  (init-env init_env (void string string))
  (init-env-tree init_env (void string content))
  (init-style init_style (void string))
  (get-style-tree get_style (tree))
  (set-style-tree change_style (void tree))
  (get-env get_env_string (string string))
  (get-env-tree get_env_value (tree string))
  (get-env-tree-at get_env_value (tree string path))
  (get-init get_init_string (string string))
  (get-init-tree get_init_value (tree string))
  (context-has? defined_at_cursor (bool string))
  (style-has? defined_at_init (bool string))
  (init-has? defined_in_init (bool string))
  (get-page-count get_page_count (int))
  (get-page-width get_page_width (int bool))
  (get-pages-width get_pages_width (int bool))
  (get-page-height get_page_height (int bool))
  (get-total-width get_total_width (int bool))
  (get-total-height get_total_height (int bool))
  (get-attachment get_att (tree string))
  (set-attachment set_att (void string content))
  (reset-attachment reset_att (void string))
  (list-attachments list_atts (array_string))

  ;; modify text
  (make-htab make_htab (void string))
  (make-space make_space (void string))
  (make-var-space make_space (void string string string))
  (make-hspace make_hspace (void string))
  (make-var-hspace make_hspace (void string string string))
  (make-vspace-before make_vspace_before (void string))
  (make-var-vspace-before make_vspace_before
    (void string string string))
  (make-vspace-after make_vspace_after (void string))
  (make-var-vspace-after make_vspace_after (void string string string))
  (make-image make_image (void string bool string string string string))

  (length-decode as_length (int string))
  (length-add add_lengths (string string string))
  (length-mult multiply_length (string double string))
  (length? is_length (bool string))
  (length-divide divide_lengths (double string string))

  ;; modify mathematics
  (cpp-make-rigid make_rigid (void))
  (cpp-make-lprime make_lprime (void string))
  (cpp-make-rprime make_rprime (void string))
  (cpp-make-below make_below (void))
  (cpp-make-above make_above (void))
  (cpp-make-script make_script (void bool bool))
  (cpp-make-fraction make_fraction (void))
  (cpp-make-sqrt make_sqrt (void))
  (cpp-make-wide make_wide (void string))
  (cpp-make-wide-under make_wide_under (void string))
  (cpp-make-var-sqrt make_var_sqrt (void))
  (cpp-make-neg make_neg (void))
  (cpp-make-tree make_tree (void))

  ;; modify tables
  (make-subtable make_subtable (void))
  (table-deactivate table_deactivate (void))
  (table-extract-format table_extract_format (void))
  (table-insert-row table_insert_row (void bool))
  (table-insert-column table_insert_column (void bool))
  (table-remove-row table_remove_row (void bool))
  (table-remove-column table_remove_column (void bool))
  (table-nr-rows table_nr_rows (int))
  (table-nr-columns table_nr_columns (int))
  (table-get-extents table_get_extents (array_int))
  (table-set-extents table_set_extents (void int int))
  (table-which-row table_which_row (int))
  (table-which-column table_which_column (int))
  (table-which-cells table_which_cells (array_int))
  
  (table-cell-path table_search_cell (path int int))
  (table-go-to table_go_to (void int int))
  (table-set-format table_set_format (void string content))
  (table-get-format-all table_get_format (tree))
  (table-get-format table_get_format (string string))
  (table-del-format table_del_format (void string))
  (table-row-decoration table_row_decoration (void bool))
  (table-column-decoration table_column_decoration (void bool))
  (table-format-center table_format_center (void))
  (table-correct-block-content table_correct_block_content (void))
  (set-cell-mode set_cell_mode (void string))
  (get-cell-mode get_cell_mode (string))
  (cell-set-format cell_set_format (void string content))
  (cell-get-format cell_get_format (string string))
  (cell-del-format cell_del_format (void string))
  (table-test table_test (void))

  ;; keyboard and mouse handling
  (key-press key_press (void string))
  (raw-emulate-keyboard emulate_keyboard (void string))
  (complete-try? complete_try (bool))
  (get-input-mode get_input_mode (int))
  (key-press-search search_keypress (bool string))
  (key-press-replace replace_keypress (bool string))
  (key-press-spell spell_keypress (bool string))
  (key-press-complete complete_keypress (bool string))
  (mouse-any mouse_any (void string int int int double))
  (get-mouse-position get_mouse_position (array_int))
  (set-mouse-pointer set_pointer (void string string))
  (set-predef-mouse-pointer set_pointer (void string))
  
  ;; moving the cursor
  (go-to-path go_to (void path))
  (go-left go_left (void))
  (go-right go_right (void))
  (go-up go_up (void))
  (go-down go_down (void))
  (go-start go_start (void))
  (go-end go_end (void))
  (go-start-of go_start_of (void tree_label))
  (go-end-of go_end_of (void tree_label))
  (go-start-with go_start_with (void string string))
  (go-end-with go_end_with (void string string))
  (go-start-line go_start_line (void))
  (go-end-line go_end_line (void))
  (go-page-up go_page_up (void))
  (go-page-down go_page_down (void))
  (go-start-paragraph go_start_paragraph (void))
  (go-end-paragraph go_end_paragraph (void))
  (go-to-label go_to_label (void string))
  (cursor-accessible? cursor_is_accessible (bool))
  (cursor-show-if-hidden show_cursor_if_hidden (void))

  ;; selections
  (select-all select_all (void))
  (select-line select_line (void))
  (select-from-cursor select_from_cursor (void))
  (select-from-keyboard select_from_keyboard (void bool))
  (select-from-shift-keyboard select_from_shift_keyboard (void))
  (select-enlarge select_enlarge (void))
  (select-enlarge-environmental select_enlarge_environmental (void))
  (selection-active-any? selection_active_any (bool))
  (selection-active-normal? selection_active_normal (bool))
  (selection-active-table? selection_active_table (bool))
  (selection-active-small? selection_active_small (bool))
  (selection-active-enlarging? selection_active_enlarging (bool))
  (selection-set-start selection_set_start (void))
  (selection-set-end selection_set_end (void))
  (selection-get-start selection_get_start (path))
  (selection-get-end selection_get_end (path))
  (selection-get-start* selection_var_get_start (path))
  (selection-get-end* selection_var_get_end (path))
  (selection-path selection_get_path (path))
  (selection-set selection_set_paths (void path path))
  (selection-set-range-set selection_set_range_set (void array_path))
  (clipboard-set selection_set (void string content))
  (clipboard-get selection_get (tree string))
  (cpp-clipboard-copy selection_copy (void string))
  (cpp-clipboard-cut selection_cut (void string))
  (clipboard-cut-at cut (void path))
  (clipboard-cut-between cut (void path path))
  (cpp-clipboard-paste selection_paste (void string))
  (selection-move selection_move (void))
  (clipboard-clear selection_clear (void string))
  (selection-cancel selection_cancel (void))
  (clipboard-set-import selection_set_import (void string))
  (clipboard-set-export selection_set_export (void string))
  (clipboard-get-import selection_get_import (string))
  (clipboard-get-export selection_get_export (string))
  (set-manual-focus-path manual_focus_set (void path))
  (get-manual-focus-path manual_focus_get (path))
  (get-focus-path focus_get (path))
  (set-alt-selection set_alt_selection (void string array_path))
  (get-alt-selection get_alt_selection (array_path string))
  (cancel-alt-selection cancel_alt_selection (void string))
  (cancel-alt-selections cancel_alt_selections (void))

  ;; undo and redo
  (clear-undo-history clear_undo_history (void))
  (commit-changes end_editing (void))
  (start-slave start_slave (void double))
  (mark-start mark_start (void double))
  (mark-end mark_end (void double))
  (mark-cancel mark_cancel (void double))
  (remove-undo-mark remove_undo_mark (void))
  (add-undo-mark add_undo_mark (void))
  (unredoable-undo unredoable_undo (void))
  (undo-possibilities undo_possibilities (int))
  (undo undo (void int))
  (redo-possibilities redo_possibilities (int))
  (redo redo (void int))
  (show-history show_history (void))
  (archive-state archive_state (void))
  (start-editing start_editing (void))
  (end-editing end_editing (void))
  (cancel-editing cancel_editing (void))

  ;; graphics
  (in-graphics? inside_graphics (bool))
  (get-graphical-x get_x (double))
  (get-graphical-y get_y (double))
  (get-graphical-object get_graphical_object (tree))
  (set-graphical-object set_graphical_object (void tree))
  (invalidate-graphical-object invalidate_graphical_object (void))
  (graphical-select graphical_select (tree double double))
  (graphical-select-area graphical_select (tree double double double double))

  ;; search, replace and spell checking
  (in-normal-mode? in_normal_mode (bool))
  (in-search-mode? in_search_mode (bool))
  (in-replace-mode? in_replace_mode (bool))
  (in-spell-mode? in_spell_mode (bool))
  (search-start search_start (void bool))
  (search-button-next search_button_next (void))
  (replace-start replace_start (void string string bool))
  (spell-start spell_start (void))
  (spell-replace spell_replace (void string))

  ;; sessions
  (session-complete-command session_complete_command (string tree))
  (custom-complete custom_complete (void tree))

  ;; miscellaneous routines
  (keyboard-focus-on keyboard_focus_on (void string))
  (view-set-property set_property (void scheme_tree scheme_tree))
  (view-get-property get_property (scheme_tree scheme_tree))
  (get-window-width get_window_width (int))
  (get-window-height get_window_height (int))
  (clear-buffer clear_buffer (void))
  (tex-buffer tex_buffer (void))
  (clear-local-info clear_local_info (void))
  (refresh-window invalidate_all (void))
  (update-path typeset_invalidate (void path))
  (update-current-buffer typeset_invalidate_all (void))
  (update-players typeset_invalidate_players (void path bool))
  (generate-all-aux generate_aux (void))
  (generate-aux generate_aux (void string))
  (notify-page-change notify_page_change (void))
  (notify-change notify_change (void int))
  (get-metadata get_metadata (string string))
  (cpp-nr-pages nr_pages (int))
  (print-to-file print_to_file (void url))
  (print-pages-to-file print_to_file (void url string string))
  (print print_buffer (void))
  (print-pages print_buffer (void string string))
  (print-snippet print_snippet (array_int url content))
  (graphics-file-to-clipboard graphics_file_to_clipboard (bool url))
  (export-postscript export_ps (void url))
  (export-pages-postscript export_ps (void url string string))
  (footer-eval footer_eval (void string))
  (texmacs-exec texmacs_exec (tree content))
  (texmacs-exec* var_texmacs_exec (tree content))
  (texmacs-expand exec_texmacs (tree content))
  (verbatim-expand exec_verbatim (tree content))
  (latex-expand exec_latex (tree content))
  (html-expand exec_html (tree content))
  (animate-checkout checkout_animation (tree content))
  (animate-commit commit_animation (tree content))
  (idle-time idle_time (int))
  (change-time change_time (int))
  (menu-before-action before_menu_action (void))
  (menu-after-action after_menu_action (void))

  (show-tree show_tree (void))
  (show-env show_env (void))
  (show-path show_path (void))
  (show-cursor show_cursor (void))
  (show-selection show_selection (void))
  (show-meminfo show_meminfo (void))
  (edit-special edit_special (void))
  (edit-test edit_test (void)))
