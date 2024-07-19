;;; at-sunset-sunrise-mode.el --- Automatically switch to dark theme at night -*- lexical-binding: t; -*-

;; Author: Your Name <your.email@example.com>
;; Maintainer: Your Name <your.email@example.com>
;; Version: 1.0
;; Package-Requires: ((emacs "24.3"))
;; Keywords: convenience, themes
;; URL: https://example.com/at-sunset-sunrise-mode

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This package provides a global minor mode to automatically switch to a dark theme
;; at night based on the sunset and sunrise times for a configured location.

;;; Code:

(require 'solar)
(require 'cl-lib)

(defvar at-sunset-sunrise-mode--last-state nil
  "Last state of the mode. Either 'sunrise or 'sunset or nil when never run.")

(defun at-sunset-sunrise-mode--run-event (event)
  "Run the hooks for the given EVENT and return EVENT."
  (let ((hook-sym (intern (format "at-sunset-sunrise-mode-%s-hook" event))))
    (cl-assert (boundp hook-sym) nil "Hook %s not defined" hook-sym)
    (run-hooks
     'at-sunset-sunrise-mode-hook
     hook-sym)
    event))

(defun at-sunset-sunrise-mode-check ()
  "Check if it is night time and enable dark theme if so."
  (interactive)
  (let* ((hours (string-to-number (format-time-string "%H")))
         (minutes (string-to-number (format-time-string "%M")))
         (time (+ (float hours) (/ minutes 60.0)))
         (sunrise-sunset (solar-sunrise-sunset (calendar-current-date)))
         (sunrise (caar sunrise-sunset))
         (sunset (caadr sunrise-sunset)))
    ;;(message "Time: %s Sunrise: %s, Sunset: %s %S" time sunrise sunset sunrise-sunset)
    (cond
     ((and (>= time sunrise) (< time sunset))
      (at-sunset-sunrise-mode--run-event 'sunrise))
     (t (at-sunset-sunrise-mode--run-event 'sunset)))))

(defvar at-sunset-sunrise-mode-hook nil "Hook run at sunset or sunrise.")
(defvar at-sunset-sunrise-mode-sunset-hook nil "Hook run at sunset.")
(defvar at-sunset-sunrise-mode-sunrise-hook nil "Hook run at sunrise.")

(defcustom at-sunset-sunrise-mode-check-interval 360 "Interval in seconds to check for night time."
  :type 'integer
  :group 'at-sunset-sunrise-mode)

(defvar at-sunset-sunrise-mode-timer nil
  "Timer to switch to dark theme at night")

(define-minor-mode at-sunset-sunrise-mode
  "Automatically switch to dark theme at night"
  :global t
  :lighter nil
  (if at-sunset-sunrise-mode
      (progn (setq at-sunset-sunrise-mode-timer
                   (run-at-time t at-sunset-sunrise-mode-check-interval #'at-sunset-sunrise-mode-check))
             (at-sunset-sunrise-mode-check))
    (when at-sunset-sunrise-mode-timer
      (cancel-timer at-sunset-sunrise-mode-timer)
      (setq at-sunset-sunrise-mode-timer nil))
    ))

(provide 'at-sunset-sunrise-mode)

;;; at-sunset-sunrise-mode.el ends here
