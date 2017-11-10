
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : build-glue-basic.scm
;; DESCRIPTION : Building basic glue
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(output-copyright "build-glue-basic.scm")

(build
  ""
  "initialize_glue_basic"

  (texmacs-version-release texmacs_version (string string))
  (version-before? version_inf (bool string string))
  (updater-supported? updater_supported (bool))
  (updater-running? updater_is_running (bool))
  (updater-check-background updater_check_background (bool))
  (updater-check-foreground updater_check_foreground (bool))
  (updater-last-check updater_last_check (long))
  (updater-set-appcast updater_set_appcast (bool url))
  (updater-set-interval updater_set_interval (bool int))
  (updater-set-automatic updater_set_automatic (bool bool))
  (get-original-path get_original_path (string))
  (os-win32? os_win32 (bool))
  (os-mingw? os_mingw (bool))
  (os-macos? os_macos (bool))
  (has-printing-cmd? has_printing_cmd (bool))
  (x-gui? gui_is_x (bool))
  (qt-gui? gui_is_qt (bool))
  (default-look-and-feel default_look_and_feel (string))
  (default-chinese-font default_chinese_font_name (string))
  (default-japanese-font default_japanese_font_name (string))
  (default-korean-font default_korean_font_name (string))
  (tm-output tm_output (void string))
  (tm-errput tm_errput (void string))
  (win32-display win32_display (void string))
  (cpp-error cpp_error (void))
  (supports-native-pdf? supports_native_pdf (bool))
  (supports-ghostscript? supports_ghostscript (bool))
  (rescue-mode? in_rescue_mode (bool))
  (scheme-dialect scheme_dialect (string))
  (get-texmacs-path get_texmacs_path (url))
  (get-texmacs-home-path get_texmacs_home_path (url))
  (plugin-list plugin_list (scheme_tree))
  (set-fast-environments set_fast_environments (void bool))
  (font-exists-in-tt? tt_font_exists (bool string))
  (eval-system eval_system (string string))
  (var-eval-system var_eval_system (string string))
  (evaluate-system evaluate_system
    (array_string array_string array_int array_string array_int))
  (get-locale-language get_locale_language (string))
  (get-locale-charset get_locale_charset (string))
  (locale-to-language locale_to_language (string string))
  (language-to-locale language_to_locale (string string))
  (texmacs-time texmacs_time (int))
  (pretty-time pretty_time (string int))
  (texmacs-memory mem_used (int))
  (bench-print bench_print (void string))
  (bench-print-all bench_print (void))
  (system-wait system_wait (void string string))
  (set-latex-command set_latex_command (void string))
  (set-bibtex-command set_bibtex_command (void string))
  (number-latex-errors number_latex_errors (int url))
  (number-latex-pages number_latex_pages (int url))
  (math-symbol-group math_symbol_group (string string))
  (math-group-members math_group_members (array_string string))
  (math-symbol-type math_symbol_type (string string))
  (object->command as_command (command object))
  (exec-delayed exec_delayed (void object))
  (exec-delayed-pause exec_delayed_pause (void object))
  (protected-call protected_call (void object))
  (notify-preferences-booted notify_preferences_booted (void))
  (cpp-has-preference? has_user_preference (bool string))
  (cpp-get-preference get_user_preference (string string string))
  (cpp-set-preference set_user_preference (void string string))
  (cpp-reset-preference reset_user_preference (void string))
  (save-preferences save_user_preferences (void))
  (set-input-language set_input_language (void string))
  (get-input-language get_input_language (string))
  (set-output-language gui_set_output_language (void string))
  (get-output-language get_output_language (string))
  (translate translate (string content))
  (string-translate translate_as_is (string string))
  (translate-from-to translate (string content string string))
  (tree-translate tree_translate (tree content))
  (tree-translate-from-to tree_translate (tree content string string))
  (force-load-translations force_load_dictionary (void string string))
  (color named_color (int string))
  (get-hex-color get_hex_color (string string))
  (named-color->xcolormap named_color_to_xcolormap (string string))
  (new-author new_author (double))
  (set-author set_author (void double))
  (get-author get_author (double))
  (debug-set debug_set (void string bool))
  (debug-get debug_get (bool string))
  (debug-message debug_message (void string string))
  (get-debug-messages get_debug_messages (tree string int))
  (clear-debug-messages clear_debug_messages (void))
  (cout-buffer cout_buffer (void))
  (cout-unbuffer cout_unbuffer (string))
  (mark-new new_marker (double))
  (glyph-register register_glyph (void string array_array_array_double))
  (glyph-recognize recognize_glyph (string array_array_array_double))
  (set-new-fonts set_new_fonts (void bool))
  (new-fonts? get_new_fonts (bool))
  (tmtm-eqnumber->nonumber eqnumber_to_nonumber (tree tree))
  (busy-versioning? is_busy_versioning (bool))
  (players-set-elapsed players_set_elapsed (void tree double))
  (players-set-speed players_set_speed (void tree double))

  ;; routines for the font database
  (tt-exists? tt_font_exists (bool string))
  (tt-dump tt_dump (void url))
  (tt-font-name tt_font_name (scheme_tree url))
  (tt-analyze tt_analyze (array_string string))
  (font-database-build font_database_build (void url))
  (font-database-build-local font_database_build_local (void))
  (font-database-extend-local font_database_extend_local (void url))
  (font-database-build-global font_database_build_global (void))
  (font-database-build-characteristics
   font_database_build_characteristics (void bool))
  (font-database-insert-global font_database_build_global (void url))
  (font-database-save-local-delta font_database_save_local_delta (void))
  (font-database-load font_database_load (void))
  (font-database-save font_database_save (void))
  (font-database-filter font_database_filter (void))
  (font-database-families font_database_families (array_string))
  (font-database-delta-families font_database_delta_families (array_string))
  (font-database-styles font_database_styles (array_string string))
  (font-database-search font_database_search (array_string string string))
  (font-database-characteristics
   font_database_characteristics (array_string string string))
  (font-database-substitutions
   font_database_substitutions (scheme_tree string))
  (font-family->master family_to_master (string string))
  (font-master->families master_to_families (array_string string))
  (font-master-features master_features (array_string string))
  (font-family-features family_features (array_string string))
  (font-family-strict-features family_strict_features (array_string string))
  (font-style-features style_features (array_string string))
  (font-guessed-features guessed_features (array_string string string))
  (font-guessed-distance guessed_distance (double string string string string))
  (font-master-guessed-distance guessed_distance (double string string))
  (font-family-guessed-features guessed_features (array_string string bool))
  (characteristic-distance
   characteristic_distance (double array_string array_string))
  (trace-distance trace_distance (double string string double))
  (logical-font-public logical_font (array_string string string))
  (logical-font-exact logical_font_exact (array_string string string))
  (logical-font-private
   logical_font (array_string string string string string))
  (logical-font-family get_family (string array_string))
  (logical-font-variant get_variant (string array_string))
  (logical-font-series get_series (string array_string))
  (logical-font-shape get_shape (string array_string))
  (logical-font-search search_font (array_string array_string))
  (logical-font-search-exact search_font_exact (array_string array_string))
  (search-font-families search_font_families (array_string array_string))
  (search-font-styles search_font_styles (array_string string array_string))
  (logical-font-patch patch_font (array_string array_string array_string))
  (logical-font-substitute apply_substitutions (array_string array_string))
  (font-family-main main_family (string string))

  ;; routines for images and animations
  (image->psdoc image_to_psdoc (string url))
  (anim-control-times get_control_times (array_double content))

  ;; routines for trees
  (tree->stree tree_to_scheme_tree (scheme_tree tree))
  (stree->tree scheme_tree_to_tree (tree scheme_tree))
  (tree->string coerce_tree_string (string tree))
  (string->tree coerce_string_tree (tree string))
  (tm->tree tree (tree content))
  (tree-atomic? is_atomic (bool tree))
  (tree-compound? is_compound (bool tree))
  (tree-label L (tree_label tree))
  (tree-children A (array_tree tree))
  (tree-arity N (int tree))
  (tree-child-ref tree_ref (tree tree int))
  (tree-child-set! tree_set (tree tree int content))
  (tree-child-insert tree_child_insert (tree content int content))
  (tree-ip obtain_ip (path tree))
  (tree-active? tree_active (bool tree))
  (tree-eq? strong_equal (bool tree tree))
  (subtree subtree (tree tree path))
  (tree-range tree_range (tree tree int int))
  (tree-copy copy (tree tree))
  (tree-append tree_append (tree tree tree))
  (tree-right-index right_index (int tree))
  (tree-label-extension? is_extension (bool tree_label))
  (tree-label-macro? is_macro (bool tree_label))
  (tree-label-parameter? is_parameter (bool tree_label))
  (tree-label-type get_tag_type (string tree_label))
  (tree-multi-paragraph? is_multi_paragraph (bool tree))
  (tree-simplify simplify_correct (tree tree))
  (tree-minimal-arity minimal_arity (int tree))
  (tree-maximal-arity maximal_arity (int tree))
  (tree-possible-arity? correct_arity (bool tree int))
  (tree-insert_point insert_point (int tree int))
  (tree-is-dynamic? is_dynamic (bool tree))
  (tree-accessible-child? is_accessible_child (bool tree int))
  (tree-accessible-children accessible_children (array_tree tree))
  (tree-all-accessible? all_accessible (bool content))
  (tree-none-accessible? none_accessible (bool content))
  (tree-name get_name (string content))
  (tree-long-name get_long_name (string content))
  (tree-child-name get_child_name (string content int ))
  (tree-child-long-name get_child_long_name (string content int))
  (tree-child-type get_child_type (string content int))
  (tree-child-env get_env_child (tree content int string content))
  (tree-descendant-env get_env_descendant (tree content path content))
  (tree-load-inclusion load_inclusion (tree url))
  (tree-as-string tree_as_string (string content))
  (tree-extents tree_extents (tree content))
  (tree-empty? is_empty (bool content))
  (tree-is-buffer? admits_edit_observer (bool tree))
  (tree-search-sections search_sections (array_tree tree))
  (tree-search-tree search (array_path content content path int))
  (tree-search-tree-at search (array_path content content path path int))
  (previous-search-hit previous_search_hit (array_path array_path path bool))
  (next-search-hit next_search_hit (array_path array_path path bool))
  (navigate-search-hit navigate_search_hit (array_path path bool bool bool))
  (tag-minimal-arity minimal_arity (int tree_label))
  (tag-maximal-arity maximal_arity (int tree_label))
  (tag-possible-arity? correct_arity (bool tree_label int))
  (set-access-mode set_access_mode (int int))
  (get-access-mode get_access_mode (int))

  (tree-assign tree_assign (tree tree content))
  (tree-var-insert tree_insert (tree tree int content))
  (tree-remove tree_remove (tree tree int int))
  (tree-split tree_split (tree tree int int))
  (tree-join tree_join (tree tree int))
  (tree-assign-node tree_assign_node (tree tree tree_label))
  (tree-insert-node tree_insert_node (tree tree int content))
  (tree-remove-node tree_remove_node (tree tree int))

  (cpp-tree-correct-node correct_node (void tree))
  (cpp-tree-correct-downwards correct_downwards (void tree))
  (cpp-tree-correct-upwards correct_upwards (void tree))

  ;; extra routines for content
  (concat-tokenize-math concat_tokenize (array_tree content))
  (concat-decompose concat_decompose (array_tree content))
  (concat-recompose concat_recompose (tree array_tree))
  (with-like? is_with_like (bool content))
  (with-same-type? with_same_type (bool content content))
  (with-similar-type? with_similar_type (bool content content))
  (with-correct with_correct (tree content))
  (with-correct-superfluous superfluous_with_correct (tree content))
  (invisible-correct-superfluous superfluous_invisible_correct (tree content))
  (invisible-correct-missing missing_invisible_correct (tree content int))
  (automatic-correct automatic_correct (tree content string))
  (manual-correct manual_correct (tree content))
  (tree-upgrade-brackets upgrade_brackets (tree content string))
  (tree-upgrade-big upgrade_big (tree content))
  (tree-downgrade-brackets downgrade_brackets (tree content bool bool))
  (tree-downgrade-big downgrade_big (tree content))
  (math-status-print math_status_print (void))
  (math-status-reset math_status_reset (void))

  ;; paths
  (path-strip strip (path path path))
  (path-inf? path_inf (bool path path))
  (path-inf-eq? path_inf_eq (bool path path))
  (path-less? path_less (bool path path))
  (path-less-eq? path_less_eq (bool path path))
  (path-start start (path content path))
  (path-end end (path content path))
  (path-next next_valid (path content path))
  (path-previous previous_valid (path content path))
  (path-next-word next_word (path content path))
  (path-previous-word previous_word (path content path))
  (path-next-node next_node (path content path))
  (path-previous-node previous_node (path content path))
  (path-next-tag next_tag (path content path scheme_tree))
  (path-previous-tag previous_tag (path content path scheme_tree))
  (path-next-tag-same-argument next_tag_same_argument
			       (path content path scheme_tree))
  (path-previous-tag-same-argument previous_tag_same_argument
				   (path content path scheme_tree))
  (path-next-argument next_argument (path content path))
  (path-previous-argument previous_argument (path content path))
  (path-previous-section previous_section (path content path))

  ;; modifications on trees
  (make-modification make_modification (modification string path content))
  (modification-assign mod_assign (modification path content))
  (modification-insert mod_insert (modification path int content))
  (modification-remove mod_remove (modification path int int))
  (modification-split mod_split (modification path int int))
  (modification-join mod_join (modification path int))
  (modification-assign-node mod_assign_node (modification path tree_label))
  (modification-insert-node mod_insert_node (modification path int content))
  (modification-remove-node mod_remove_node (modification path int))
  (modification-set-cursor mod_set_cursor (modification path int content))
  (modification-kind get_type (string modification))
  (modification-path get_path (path modification))
  (modification-tree get_tree (tree modification))
  (modification-root root (path modification))
  (modification-index index (int modification))
  (modification-argument argument (int modification))
  (modification-label L (tree_label modification))

  (modification-copy copy (modification modification))
  (modification-applicable? is_applicable (bool content modification))
  (modification-apply var_clean_apply (tree content modification))
  (modification-inplace-apply var_apply (tree tree modification))
  (modification-invert invert (modification modification content))
  (modification-commute? commute (bool modification modification))
  (modification-can-pull? can_pull (bool modification modification))
  (modification-pull pull (modification modification modification))
  (modification-co-pull co_pull (modification modification modification))

  ;; patches
  (patch-pair patch (patch modification modification))
  (patch-compound patch (patch array_patch))
  (patch-branch branch_patch (patch array_patch))
  (patch-birth patch (patch double bool))
  (patch-author patch (patch double patch))
  (patch-pair? is_modification (bool patch))
  (patch-compound? is_compound (bool patch))
  (patch-branch? is_branch (bool patch))
  (patch-birth? is_birth (bool patch))
  (patch-author? is_author (bool patch))
  (patch-arity N (int patch))
  (patch-ref access (patch patch int))
  (patch-direct get_modification (modification patch))
  (patch-inverse get_inverse (modification patch))
  (patch-get-birth get_birth (bool patch))
  (patch-get-author get_author (double patch))

  (patch-copy copy (patch patch))
  (patch-applicable? is_applicable (bool patch content))
  (patch-apply var_clean_apply (tree content patch))
  (patch-inplace-apply var_apply (tree tree patch))
  (patch-compactify compactify (patch patch))
  (patch-cursor-hint cursor_hint (path patch content))
  (patch-invert invert (patch patch content))
  (patch-commute? commute (bool patch patch))
  (patch-can-pull? can_pull (bool patch patch))
  (patch-pull pull (patch patch patch))
  (patch-co-pull co_pull (patch patch patch))
  (patch-remove-set-cursor remove_set_cursor (patch patch))
  (patch-modifies? does_modify (bool patch))

  ;; links
  (tree->ids get_ids (list_string tree))
  (id->trees get_trees (list_tree string))
  (vertex->links get_links (list_tree content))
  (tree->tree-pointer tree_pointer_new (observer tree))
  (tree-pointer-detach tree_pointer_delete (void observer))
  (tree-pointer->tree obtain_tree (tree observer))
  (current-link-types all_link_types (list_string))
  (get-locus-rendering get_locus_rendering (string string))
  (set-locus-rendering set_locus_rendering (void string string))
  (declare-visited declare_visited (void string))
  (has-been-visited? has_been_visited (bool string))

  (graphics-set set_graphical_value (void content content))
  (graphics-has? has_graphical_value (bool content))
  (graphics-ref get_graphical_value (tree content))
  (graphics-needs-update? graphics_needs_update (bool))
  (graphics-notify-update graphics_notify_update (void content))

  ;; routines for strings
  (string-number? is_double (bool string))
  (string-occurs? occurs (bool string string))
  (string-count-occurrences count_occurrences (int string string))
  (string-search-forwards search_forwards (int string int string))
  (string-search-backwards search_backwards (int string int string))
  (string-overlapping overlapping (int string string))
  (string-replace replace (string string string string))
  (string-alpha? is_alpha (bool string))
  (string-locase-alpha? is_locase_alpha (bool string))
  (upcase-first upcase_first (string string))
  (locase-first locase_first (string string))
  (upcase-all upcase_all (string string))
  (locase-all locase_all (string string))
  (string-union string_union (string string string))
  (string-minus string_minus (string string string))
  (escape-generic escape_generic (string string))
  (escape-verbatim escape_verbatim (string string))
  (escape-shell escape_sh (string string))
  (escape-to-ascii cork_to_ascii (string string))
  (unescape-guile unescape_guile (string string))
  (string-quote scm_quote (string string))
  (string-unquote scm_unquote (string string))
  (string-convert convert (string string string string))
  (encode-base64 encode_base64 (string string))
  (decode-base64 decode_base64 (string string))
  (sourcecode->cork sourcecode_to_cork (string string))
  (cork->sourcecode cork_to_sourcecode (string string))
  (utf8->cork utf8_to_cork (string string))
  (cork->utf8 cork_to_utf8 (string string))
  (utf8->t2a utf8_to_t2a (string string))
  (t2a->utf8 t2a_to_utf8 (string string))
  (utf8->html utf8_to_html (string string))
  (guess-wencoding guess_wencoding (string string))
  (tm->xml-name tm_to_xml_name (string string))
  (old-tm->xml-cdata old_tm_to_xml_cdata (string string))
  (tm->xml-cdata tm_to_xml_cdata (object string))
  (xml-name->tm xml_name_to_tm (string string))
  (old-xml-cdata->tm old_xml_cdata_to_tm (string string))
  (xml-unspace xml_unspace (string string bool bool))
  (integer->hexadecimal as_hexadecimal (string int))
  (integer->padded-hexadecimal as_hexadecimal (string int int))
  (hexadecimal->integer from_hexadecimal (int string))
  (cpp-string-tokenize tokenize (array_string string string))
  (cpp-string-recompose recompose (string array_string string))
  
  ; Program bracket matching
  (find-left-bracket find_left_bracket (path path string string))
  (find-right-bracket find_right_bracket (path path string string))

  ;; routines for strings in the TeXmacs encoding
  (string->tmstring tm_encode (string string))
  (tmstring->string tm_decode (string string))
  (tmstring-length tm_string_length (int string))
  (tmstring-ref tm_forward_access (string string int))
  (tmstring-reverse-ref tm_backward_access (string string int))
  (tmstring->list tm_tokenize (array_string string))
  (list->tmstring tm_recompose (string array_string))
  (string-next tm_char_next (int string int))
  (string-previous tm_char_previous (int string int))
  (tmstring-split tm_string_split (array_string string))

  (tmstring-translit uni_translit (string string))
  (tmstring-locase-first uni_locase_first (string string))
  (tmstring-upcase-first uni_upcase_first (string string))
  (tmstring-locase-all uni_locase_all (string string))
  (tmstring-upcase-all uni_upcase_all (string string))
  (tmstring-unaccent-all uni_unaccent_all (string string))
  (tmstring-before? uni_before (bool string string))

  ;; Packrat grammar and parsing tools
  (packrat-define packrat_define (void string string tree))
  (packrat-property packrat_property (void string string string string))
  (packrat-inherit packrat_inherit (void string string))
  (packrat-parse packrat_parse (path string string content))
  (packrat-correct? packrat_correct (bool string string content))
  (packrat-context packrat_context (object string string content path))
  (syntax-read-preferences initialize_color_decodings (void string))
  
  ;; further conversion routines for trees and strings
  (parse-texmacs texmacs_document_to_tree (tree string))
  (serialize-texmacs tree_to_texmacs (string tree))
  (parse-texmacs-snippet texmacs_to_tree (tree string))
  (serialize-texmacs-snippet tree_to_texmacs (string tree))
  (texmacs->stm tree_to_scheme (string tree))
  (stm->texmacs scheme_document_to_tree (tree string))
  (stm-snippet->texmacs scheme_to_tree (tree string))
  (cpp-texmacs->verbatim tree_to_verbatim (string tree bool string))
  (cpp-verbatim-snippet->texmacs verbatim_to_tree (tree string bool string))
  (cpp-verbatim->texmacs verbatim_document_to_tree (tree string bool string))
  (parse-latex parse_latex (tree string))
  (parse-latex-document parse_latex_document (tree string))
  (latex->texmacs latex_to_tree (tree tree))
  (cpp-latex-document->texmacs latex_document_to_tree (tree string bool))
  (latex-class-document->texmacs latex_class_document_to_tree (tree string))
  (tracked-latex->texmacs tracked_latex_to_texmacs (tree string bool))
  (conservative-texmacs->latex conservative_texmacs_to_latex
                               (string content object))
  (tracked-texmacs->latex tracked_texmacs_to_latex (string content object))
  (conservative-latex->texmacs conservative_latex_to_texmacs (tree string bool))
  (get-line-number get_line_number (int string int))
  (get-column-number get_column_number (int string int))
  (try-latex-export try_latex_export (tree content object url url))
  (parse-xml parse_xml (scheme_tree string))
  (parse-html parse_html (scheme_tree string))
  (parse-bib parse_bib (tree string))
  (conservative-bib-import conservative_bib_import
                           (tree string content string))
  (conservative-bib-export conservative_bib_export
                           (string content string content))
  (upgrade-tmml tmml_upgrade (tree scheme_tree))
  (upgrade-mathml upgrade_mathml (tree content))
  (vernac->texmacs vernac_to_tree (tree string))
  (vernac-document->texmacs vernac_document_to_tree (tree string))
  (compute-keys-string compute_keys (array_string string string))
  (compute-keys-tree compute_keys (array_string content string))
  (compute-keys-url compute_keys (array_string url))
  (compute-index-string compute_index (scheme_tree string string))
  (compute-index-tree compute_index (scheme_tree content string))
  (compute-index-url compute_index (scheme_tree url))

  ;; routines for urls
  (url->url url (url url))
  (root->url url_root (url string))
  (string->url url (url string))
  (url->string as_string (string url))
  (url->stree as_tree (scheme_tree url))
  (system->url url_system (url string))
  (url->system as_system_string (string url))
  (unix->url url_unix (url string))
  (url->unix as_unix_string (string url))
  (url-unix url (url string string))
  (url-none url_none (url))
  (url-any url_wildcard (url))
  (url-wildcard url_wildcard (url string))
  (url-pwd url_pwd (url))
  (url-parent url_parent (url))
  (url-ancestor url_ancestor (url))
  (url-append url_concat (url url url))
  (url-or url_or (url url url))
  (url-none? is_none (bool url))
  (url-rooted? is_rooted (bool url))
  (url-rooted-protocol? is_rooted (bool url string))
  (url-rooted-web? is_rooted_web (bool url))
  (url-rooted-tmfs? is_rooted_tmfs (bool url))
  (url-rooted-tmfs-protocol? is_rooted_tmfs (bool url string))
  (url-root get_root (string url))
  (url-unroot unroot (url url))
  (url-atomic? is_atomic (bool url))
  (url-concat? is_concat (bool url))
  (url-or? is_or (bool url))
  (url-ref url_ref (url url int))
  (url-head head (url url))
  (url-tail tail (url url))
  (url-format file_format (string url))
  (url-suffix suffix (string url))
  (url-basename basename (string url))
  (url-glue glue (url url string))
  (url-unglue unglue (url url int))
  (url-relative relative (url url url))
  (url-expand expand (url url))
  (url-factor factor (url url))
  (url-delta delta (url url url))
  (url-secure? is_secure (bool url))
  (url-descends? descends (bool url url))

  (url-complete complete (url url string))
  (url-resolve resolve (url url string))
  (url-resolve-in-path resolve_in_path (url url))
  (url-exists? exists (bool url))
  (url-exists-in-path? exists_in_path (bool url))
  (url-exists-in-tex? exists_in_tex (bool url))
  (url-concretize concretize (string url))
  (url-materialize materialize (string url string))
  (url-test? is_of_type (bool url string))
  (url-regular? is_regular (bool url))
  (url-directory? is_directory (bool url))
  (url-link? is_symbolic_link (bool url))
  (url-newer? is_newer (bool url url))
  (url-size file_size (int url))
  (url-last-modified last_modified (int url))
  (url-temp url_temp (url))
  (url-scratch url_scratch (url string string int))
  (url-scratch? is_scratch (bool url))
  (url-cache-invalidate web_cache_invalidate (void url))
  (string-save string_save (void string url))
  (string-load string_load (string url))
  (string-append-to-file string_append_to_file (void string url))
  (system-move move (void url url))
  (system-copy copy (void url url))
  (system-remove remove (void url))
  (system-mkdir mkdir (void url))
  (system-rmdir rmdir (void url))
  (system-search-score search_score (int url array_string))
  (system-1 system (void string url))
  (system-2 system (void string url url))
  (system-url->string sys_concretize (string url))
  (url-grep grep (url string url))
  (url-search-upwards search_file_upwards (url url string array_string))

  ;; Persistent data
  (persistent-set persistent_set (void url string string))
  (persistent-remove persistent_reset (void url string))
  (persistent-has? persistent_contains (bool url string))
  (persistent-get persistent_get (string url string))
  (persistent-file-name persistent_file_name (url url string))

  ;; native TeXmacs databases
  (tmdb-keep-history keep_history (void url bool))
  (tmdb-set-field set_field (void url string string array_string double))
  (tmdb-get-field get_field (array_string url string string double))
  (tmdb-remove-field remove_field (void url string string double))
  (tmdb-get-attributes get_attributes (array_string url string double))
  (tmdb-set-entry set_entry (void url string scheme_tree double))
  (tmdb-get-entry get_entry (scheme_tree url string double))
  (tmdb-remove-entry remove_entry (void url string double))
  (tmdb-query query (array_string url scheme_tree double int))
  (tmdb-inspect-history inspect_history (void url string))
  (tmdb-get-completions get_completions (array_string url string))
  (tmdb-get-name-completions get_name_completions (array_string url string))

  ;; SQL interface
  (supports-sql? sqlite3_present (bool))
  (sql-exec sql_exec (scheme_tree url string))
  (sql-quote sql_quote (string string))

  ;; TeXmacs servers and clients
  (server-start server_start (void))
  (server-stop server_stop (void))
  (server-read server_read (string int))
  (server-write server_write (void int string))
  (server-started? server_started (bool))
  (client-start client_start (int string))
  (client-stop client_stop (void int))
  (client-read client_read (string int))
  (client-write client_write (void int string))
  (enter-secure-mode enter_secure_mode (void int))

  ;; connections to extern systems
  (connection-start connection_start (string string string))
  (connection-status connection_status (int string string))
  (connection-write-string connection_write (void string string string))
  (connection-write connection_write (void string string content))
  (connection-cmd connection_cmd (tree string string string))
  (connection-eval connection_eval (tree string string content))
  (connection-interrupt connection_interrupt (void string string))
  (connection-stop connection_stop (void string string))

  ;; widgets
  (widget-printer printer_widget (widget command url))
  (widget-color-picker color_picker_widget (widget command bool array_tree))
  (widget-extend extend (widget widget array_widget))
  (widget-hmenu horizontal_menu (widget array_widget))
  (widget-vmenu vertical_menu (widget array_widget))
  (widget-tmenu tile_menu (widget array_widget int))
  (widget-minibar-menu minibar_menu (widget array_widget))
  (widget-separator menu_separator (widget bool))
  (widget-menu-group menu_group (widget string int))
  (widget-pulldown-button pulldown_button (widget widget promise_widget))
  (widget-pullright-button pullright_button (widget widget promise_widget))
  (widget-menu-button menu_button (widget widget command string string int))
  (widget-toggle toggle_widget (widget command bool int))
  (widget-balloon balloon_widget (widget widget widget))
  (widget-empty empty_widget (widget))
  (widget-text text_widget (widget string int int bool))
  (widget-input input_text_widget
		(widget command string array_string int string))
  (widget-enum enum_widget (widget command array_string string int string))
  (widget-choice choice_widget (widget command array_string string))
  (widget-choices choice_widget (widget command array_string array_string))
  (widget-filtered-choice choice_widget
    (widget command array_string string string))
  (widget-tree-view tree_view_widget (widget command tree tree))
  (widget-xpm xpm_widget (widget url))
  (widget-box box_widget (widget scheme_tree string int bool bool))
  (widget-glue glue_widget (widget bool bool int int))
  (widget-color glue_widget (widget content bool bool int int))
  (widget-hlist horizontal_list (widget array_widget))
  (widget-vlist vertical_list (widget array_widget))
  (widget-aligned aligned_widget (widget array_widget array_widget))
  (widget-tabs tabs_widget (widget array_widget array_widget))
  (widget-icon-tabs icon_tabs_widget (widget array_url array_widget
                                             array_widget))
  (widget-scrollable user_canvas_widget (widget widget int))
  (widget-resize resize_widget (widget widget int string string string string
                                       string string string string))
  (widget-hsplit hsplit_widget (widget widget widget))
  (widget-vsplit vsplit_widget (widget widget widget))
  (widget-texmacs-output texmacs_output_widget (widget content content))
  (widget-texmacs-input texmacs_input_widget (widget content content url))
  (widget-ink ink_widget (widget command))
  (widget-refresh refresh_widget (widget string string))
  (widget-refreshable refreshable_widget (widget object string))
  (object->promise-widget as_promise_widget (promise_widget object))
  (tree-bounding-rectangle get_bounding_rectangle (array_int tree))
  (widget-size get_widget_size (array_int widget))
  (show-balloon show_help_balloon (void widget int int))
  (get-style-menu get_style_menu (object))
  (hidden-package? hidden_package (bool string))
  (get-add-package-menu get_add_package_menu (object))
  (get-remove-package-menu get_remove_package_menu (object))
  (get-toggle-package-menu get_toggle_package_menu (object))
  (refresh-now windows_refresh (void string))

  ;; buffers
  (buffer-list get_all_buffers (array_url))
  (current-buffer-url get_current_buffer_safe (url))
  (path-to-buffer path_to_buffer (url path))
  (buffer-new make_new_buffer (url))
  (buffer-rename rename_buffer (void url url))
  (buffer-set set_buffer_tree (void url content))
  (buffer-get get_buffer_tree (tree url))
  (buffer-set-body set_buffer_body (void url content))
  (buffer-get-body get_buffer_body (tree url))
  (buffer-set-master set_master_buffer (void url url))
  (buffer-get-master get_master_buffer (url url))
  (buffer-set-title set_title_buffer (void url string))
  (buffer-get-title get_title_buffer (string url))
  (buffer-last-save get_last_save_buffer (int url))
  (buffer-last-visited last_visited (double url))
  (buffer-modified? buffer_modified (bool url))
  (buffer-modified-since-autosave? buffer_modified_since_autosave (bool url))
  (buffer-pretend-modified pretend_buffer_modified (void url))
  (buffer-pretend-saved pretend_buffer_saved (void url))
  (buffer-pretend-autosaved pretend_buffer_autosaved (void url))
  (buffer-attach-notifier attach_buffer_notifier (void url))
  (buffer-has-name? buffer_has_name (bool url))
  (buffer-aux? is_aux_buffer (bool url))
  (buffer-import buffer_import (bool url url string))
  (buffer-load buffer_load (bool url))
  (buffer-export buffer_export (bool url url string))
  (buffer-save buffer_save (bool url))
  (tree-import-loaded import_loaded_tree (tree string url string))
  (tree-import import_tree (tree url string))
  (tree-export export_tree (bool tree url string))
  (tree-load-style load_style_tree (tree string))
  (buffer-focus focus_on_buffer (bool url))

  (view-list get_all_views (array_url))
  (buffer->views buffer_to_views (array_url url))
  (current-view-url get_current_view_safe (url))
  (window->view window_to_view (url url))
  (view->buffer view_to_buffer (url url))
  (view->window-url view_to_window (url url))
  (view-new get_new_view (url url))
  (view-passive get_passive_view (url url))
  (view-recent get_recent_view (url url))
  (view-delete delete_view (void url))
  (window-set-view window_set_view (void url url bool))
  (switch-to-buffer switch_to_buffer (void url))

  (window-list windows_list (array_url))
  (windows-number get_nr_windows (int))
  (current-window get_current_window (url))
  (buffer->windows buffer_to_windows (array_url url))
  (window-to-buffer window_to_buffer (url url))
  (window-set-buffer window_set_buffer (void url url))
  (window-focus window_focus (void url))

  (new-buffer create_buffer (url))
  (open-buffer-in-window new_buffer_in_new_window (url url content content))
  (open-window open_window (url))
  (open-window-geometry open_window (url content))
  (clone-window clone_window (void))
  (buffer-close kill_buffer (void url))
  (kill-window kill_window (void url))
  (kill-current-window-and-buffer kill_current_window_and_buffer (void))

  (project-attach project_attach (void string))
  (project-detach project_attach (void))
  (project-attached? project_attached (bool))
  (project-get project_get (url))

  ;; transitional alternative windows; to be replaced by better solution
  (alt-window-handle window_handle (int))
  (alt-window-create window_create (void int widget string bool))
  (alt-window-create-quit window_create (void int widget string command))
  (alt-window-delete window_delete (void int))
  (alt-window-show window_show (void int))
  (alt-window-hide window_hide (void int))
  (alt-window-get-size window_get_size (scheme_tree int))
  (alt-window-set-size window_set_size (void int int int))
  (alt-window-get-position window_get_position (scheme_tree int))
  (alt-window-set-position window_set_position (void int int int))

  ;; routines for BibTeX
  (bibtex-run bibtex_run (tree string string url array_string))
  (bib-add-period bib_add_period (scheme_tree scheme_tree))
  (bib-locase-first bib_locase_first (scheme_tree scheme_tree))
  (bib-upcase-first bib_upcase_first (scheme_tree scheme_tree))
  (bib-locase bib_locase (scheme_tree scheme_tree))
  (bib-upcase bib_upcase (scheme_tree scheme_tree))
  (bib-default-preserve-case bib_default_preserve_case (scheme_tree scheme_tree))
  (bib-default-upcase-first bib_default_upcase_first (scheme_tree scheme_tree))
  (bib-purify bib_purify (string scheme_tree))
  (bib-text-length bib_text_length (int scheme_tree))
  (bib-prefix bib_prefix (string scheme_tree int))
  (bib-empty? bib_empty (bool scheme_tree string))
  (bib-field bib_field (scheme_tree scheme_tree string))
  (bib-abbreviate bib_abbreviate
		  (scheme_tree scheme_tree scheme_tree scheme_tree)))
