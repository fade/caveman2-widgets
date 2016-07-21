;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This file is a part of the caveman2-widgets project.
;;
;; Copyright (c) 2016 Richard Paul Bäck (richard.baeck@free-your-pc.com)
;; LICENSE: LLGPLv3
;;
;; Purpose:
;; --------
;; This package provides an accessor to a session flag which decides
;; if a requester's session is logged in or not. Further it implements
;; a full login procedure.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :cl-user)
(defpackage caveman2-widgets.login
  (:use :cl
        :caveman2
        :caveman2-widgets.util
        :caveman2-widgets.widget
        :caveman2-widgets.widgets
        :caveman2-widgets.callback-widget)
  (:export
   :*login-authentication-keyword*
   :logged-in

   :<login-widget>
   :authenticator
   :logout-button))
(in-package :caveman2-widgets.login)

(defvar *login-authentication-keyword*
  :logged-in-flag
  "This variable holds the keyword which is used within the session to
indicated that a session holder is logged in (or not).")

(defgeneric logged-in (session))
(defmethod logged-in ((session hash-table))
  (gethash *login-authentication-keyword* *session*))

(defgeneric (setf logged-in) (value session))

(defmethod (setf logged-in) (value (session hash-table))
  (setf (gethash *login-authentication-keyword* *session*)
        value))

(defclass <login-widget> (<composite-widget>)
  ((authenticator
    :initarg :authenticator
    :reader authenticator
    :initform #'(lambda () nil))
   (logout-button
    :initform
    (make-widget
     :session '<button-widget>
     :label "Logout"
     :callback
     #'(lambda ()
         (setf (logged-in *session*)
               nil)))
    :reader logout-button)))

(defmethod render-widget ((this <login-widget>))
  (with-output-to-string (ret-val)
    (if (logged-in *session*)
        (with-output-to-string (ret-val)
          (format ret-val (call-next-method this))
          (format ret-val (render-widget
                           (logout-button this))))
        (with-output-to-string (ret-val)
          (format
           ret-val
           (render-widget
            (make-widget
             :session '<button-widget>
             :label "Login"
             :callback
             #'(lambda ()
                 (setf (logged-in *session*)
                       t)
                 (mark-dirty this)))))))))
