(in-package :next)

(defvar *gtk-webkit-command* "next-gtk-webkit"
  "Path to the GTK-Webkit platform port executable.")
(defvar *gtk-webkit-args* (list "--port" (write-to-string (getf *platform-port-socket* :port))
                                "--core-socket" (format nil "http://localhost:~a/RPC2" *core-port*))
  "Arguments to pass to the GTK-Webkit platform port executable.")
(defvar *gtk-webkit-log* #P"/tmp/next-gtk-webkit.log"
  "Where to store the log of the GTK-Webkit platform port.")

(defclass port ()
  ((running-process :accessor running-process)))

(defmethod set-conversion-table ((port port))
  (setf (gethash "SPACE" *character-conversion-table*) " ")
  (setf (gethash "BACKSPACE" *character-conversion-table*) "")
  (setf (gethash "DELETE" *character-conversion-table*) "")
  (setf (gethash "RETURN" *character-conversion-table*) "")
  (setf (gethash "HYPHEN" *character-conversion-table*) "-")
  (setf (gethash "ESCAPE" *character-conversion-table*) ""))

(defmethod run-loop ((port port))
  (uiop:wait-process (running-process port)))

(defmethod run-program ((port port))
  (setf (running-process port)
        (uiop:launch-program (cons *gtk-webkit-command* *gtk-webkit-args*)
                             :output *gtk-webkit-log*
                             :error-output :output)))

(defmethod kill-program ((port port))
  (uiop:run-program
   (list "kill" "-15"
         (write-to-string
          (uiop/launch-program:process-info-pid
           (running-process port))))))
