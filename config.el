;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "George Gkioulis"
      user-mail-address "george.gkioulis@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/.org-notes/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Make key s act as vim substitute
(remove-hook 'doom-first-input-hook #'evil-snipe-mode)

;; Make tabs act as they would in vim
(define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)

;; C-return is interpreted as C-j in no window mode
;; With this change C-j (and C-ret in no window mode) inserts item below
(map! :map 'override "C-j" #'+org/insert-item-below)

;; Set default directory
(setq default-directory "~/.org-notes/")

;; Set org-mode variables
(after! org
 (custom-set-variables
   '(org-directory "~/.org-notes/")
   '(org-agenda-files (directory-files-recursively org-directory "\\.org$")))
   (setq org-todo-keywords '((sequence "TODO(t)" "WIP(w)" "BLOCKED(b)" "FEEDBACK(f)" "|"
   "DONE(d)" "REJECTED(r)")))
   (setq org-todo-keyword-faces
     '(("WIP" . "orange") ("BLOCKED" . "red")))
)

;; Enable undo-tree-mode to all buffers
(define-globalized-minor-mode my-global-undo-tree-mode undo-tree-mode
  (lambda () (undo-tree-mode 1)))
(my-global-undo-tree-mode 1)

;; On text-mode, enable the display-fill-column-indicator-mode to show a vertical column
;; After display-fill-column-indicator-mode is loaded set vertical column to position 110
(add-hook 'text-mode-hook 'display-fill-column-indicator-mode)
(after! display-fill-column-indicator
 (setq-default fill-column 110)
)

;; Disable clipboard
;; Now you must use + register to paste to and from clipboard
(setq select-enable-clipboard nil)

;; Disable auto-pairs (eg do not insert two quotes when only one was typed)
;; (remove-hook 'doom-first-buffer-hook #'smartparens-global-mode)

(setq doom-font (font-spec :size 13))

;; Send undo tree files to .config/emacs/undo dir, to keep your repo clean
(setq undo-tree-history-directory-alist '(("." . "~/.config/emacs/undo")))

;; Turn off autocompletion
(setq company-idle-delay nil)

;; Save recent files every 5 mins
(run-at-time "5 min" 300 'recentf-save-list)

;; Make sure that tab-width stays 4 after the changes in org version 9.7
;; check with ctrl-h-v tab-width
(defun my/force-tab-width-in-org ()
  (when (derived-mode-p 'org-mode)
    (setq tab-width 4)))
(add-hook 'after-change-major-mode-hook #'my/force-tab-width-in-org)

;; Export anki notes. Entries starting with + or - are the question
;; Everything under that entry is the answer
(defun anki/export-notes-to-csv (file)
  (interactive "FExport notes to: ")
  (let ((regex (rx bol (in "+-") " " (group (1+ nonl))))
        (buf (find-file-noselect file))
        (output ""))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward regex nil t)
        (let ((question (match-string 1))
              (answer "")
              (start (line-end-position)))
          (save-excursion
            (goto-char start)
            (while (and (forward-line 1)
                        (looking-at "^[ \t]+\\(.*\\)$"))
              (setq answer (concat answer " " (match-string 1)))))
          (setq output (concat output (format "%s;%s\n" question (string-trim answer)))))))
    (with-current-buffer buf
      (erase-buffer)
      (insert output)
      (save-buffer))
    (kill-buffer buf)
    (message "Export done.")))

