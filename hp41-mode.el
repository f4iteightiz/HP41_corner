;; file hp41-mode.el --- Major mode for HP-41 RPN (FOCAL) programming
;;
;; can be located in /home/userXYZ/.emacs.d
;; then put following command in the ~.emacs file in /home/userXYZ
;;   (load "/home/userXYZ/.emacs.d/hp41-mode.el")
;; or anywhere else then start emacs with
;;   emacs  -q --load '/home/userXYZ/.emacs.d/hp41-mode.el'
;;   .. for making sure only the hp41 highligting is done, especially 
;;      when your .emacs file is busy with other setups
;;
;; copyright CC BY-NC 4.0
;; pascaldagornet dot yahoo dot de
;; https://creativecommons.org/licenses/by-nc/4.0/
;;
;; similar to this for vim https://github.com/isene/hp-41_vim
;;
;; constructed with the help of GEMINI
;;   which made reference to https://www.thimet.de/CalcCollection/Calculators/HP-41/HP-41-Commands.pdf
;; asking 1 can you please submit a code proposal for creating a syntax highlight for RPN HP41 in emacs
;; asking 2 (result dont work) please update the code for having now "ST+" in the same fonts than "STO"
;; asking 3 how to highlight the register X Y Z T L M N O P with the inverted font of font-lock-variable-name-face
;; asking 4 how to highlight X^2 like CHS without considering the 2 in the expression
;; asking 5 how to highlight X=0? like X<Y?  without considering the 0 in the expression
;; asking 6 (not implemented) How to extend the setup for using the CC41 program from https://github.com/CraigBladow/cc41: first using the command for loading the file on the screen with ./HP41/CC41/cc41 -L file.hp41 then using the sst cli command for moving step by step
;; 
;; testing
;; download an HP41 file like https://github.com/f4iteightiz/ellipse_iso_perimeter/blob/main/ELPER.TXT
;; change the extension from .TXT to .rpn or .hp41
;; start emacs with
;;   emacs /home/userXYZ/ELPER.hp41
;; or
;;   emacs -debug-init /home/userXYZ/ELPER.hp41    ; debugging this init hp41-mode.el file if emacs found it
;; or
;;   emacs  -q --load '/home/userXYZ/.emacs.d/hp41-mode.el' /home/userXYZ/ELPER.hp41 
;; or
;;   emacs  -q --load '/home/userXYZ/.emacs.d/hp41-mode.el' /home/userXYZ/ELPER.hp41  /home/userXYZ/file2.hp41  --eval "(view-files-in-windows)"
;; 
;; TODO:
;; [ ] test test test..
;; [ ] more module function list
;; [ ] take non programmable fct out
;; [ ] link it to cc41 (like with prolog-swipl or riscv-spike or forth-gforth)
;; [ ] case unsensitive
;; [ ] more comments from thimet seen when mouse is over the word
;; [ ] ARCL and CLA highligting to be improved
;; [ ] X>Y? X<>Y X<> .. too
;; [ ] IND from 82160A .. too
;; [ ] ..
;; [ ] ..
;;
;; change log
;; 2025.12.24 Creation
;; 2025.12.26 Upload Github
;; 2025.12.28 GTO instead of GOTO; dark mode
;; 2026.01.03 XEQ IND new; comments when mouse over command. BST CAT taken out
;; YYYY.MM.DD
;; YYYY.MM.DD
;;
;; added 2025.12.28 it creates now a dark mode
;; takes it out if you wish a light mode
;; >>>>>
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-enabled-themes '(misterioso))
 '(display-line-numbers-type 'relative)
 '(global-display-line-numbers-mode t)
 '(line-number-mode nil)
 '(package-selected-packages '(debbugs ahungry-theme ztree)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; <<<<<
;;
;; >>>>>
;; https://superuser.com/questions/292865/how-to-open-more-than-2-files-in-a-single-emacs-frame
 (defun view-files-in-windows ()
  (ibuffer)                      ; Activate ibuffer mode.
  (ibuffer-mark-special-buffers) ; Mark the special buffers.
  (ibuffer-toggle-marks)         ; Toggle buffers, leaving the non-special ones
  (ibuffer-do-view))             ; Show each buffer in a different window.
;; <<<<<
;;
;; 1. Define a custom face for HP-41 specific registers
(defface hp41-register-face
  '((t :inherit font-lock-variable-name-face :inverse-video t))
  "Face for HP-41 stack registers (X, Y, Z, T, L) and alpha registers (M, N, O)."
  :group 'hp41)
;;
;; 2. Define a custom face for HP-41 flags
;; font-lock-type-face not used so far
(defface hp41-flags-face
  '((t :inherit font-lock-type-face :inverse-video t))
  "Face for flag words"
  :group 'hp41)
;;
;;
(defvar hp41-font-lock-keywords
  (let* (;; Core stack and math operations
         (operators '("+" "-" "*" "/" "1/X" "SQRT" "LOG" "LN" 
         "EXP" "10^X" "ABS" "SIGN" "E^X" "E^X-1" "FACT" "LN1+X" 
         "MEAN" "MOD" "Y^X" "CHS" "ACOS" "SIN" "COS" "TAN" 
         "RND"  "FRC" "X^2" "ASIN" "ATAN" "P-R" "HMS" "HMS+" 
         "HMS-" "HR" "INT" "PI" "R-D" "R-P" "%" "%CH"
         ))
         ;;
         (41cx '("CLALMA" "CLALMX" "CLRALMS" "RCLALM" "SWPT"
         ))
         ;; 82182A Time Module
         (timemod '("ATIME" "ADATE" "SETIME" "SETDATE" "CLOCK" 
         "T+X" "CLKTD" "CLK12" "ALMCAT" "ALMNOW" "ATIME24" 
         "CLK24" "CLKT" "CORRECT" "DATE" "DATE+" "DDAYS" "DMY" 
         "DOW" "MDY" "RCLAF" "RCLSW" "RUNSW" "SETAF" "SETSW" 
         "STOPSW" "SW" "TIME" "XYZALM"
         ))
         ;; 82180A Extended Functions
         (extfct '("ALENG" "ANUM" "APPCHR" "APPREC" "ARCLREC" "AROT"
                    "ATOX" "CLFL" "CLKEYS" "CRFLAS" "CRFLD" "DELCHR"
                    "DELREC" "EMDIR" "FLSIZE" "GETAS" "GETKEY" "GETP"
                    "GETR" "GETREC" "GETRX" "GETSUB" "GETX" "INSCHR"
                    "INSREC" "PASN" "PCLPS" "POSA" "POSFL" "PSIZE"
                    "PURFL" "RCLFLAG" "RCLPT" "RCLPTA" "REGMOVE" 
                    "REGSWAP" "SAVEAS" "SAVEP" "SAVER" "SAVERX" "SAVEX"
                    "SEEKPT" "SEEKPTA" "SIZE?" "STOFLAG" "X<>F" "XTOA"
         ))
         ;; 82160A HP-IL Module
                  (ilmod '("OUTA" "SPOLL"
                    ;; Control fct
                    "AUTOIO" "FINDID" "INA" 
;;                    "IND"         ;; check conflicts with XEQ IND etc.
                    "INSTAT" "LISTEN"
                    "LOCAL" "MANIO" "OUTA" "PWRDN" "PWRUP" "REMOTE"
                    "SELECT" "STOPIO" "TRIGGER"
                    ;; Printer
                    "ACA" "ACCHR" "ACCOL" "ACSPEC" "ACX" "BLDSPEC"
                    "LIST" "PRA" "`PRAXIS" "PRBUF" "PRFLAGS" "PRKEYS"
                    "PRP" "`PRPLOT" "`PRPLOTP" "PRREG" "PRREGX" "PRs"
                    "PRSTK" "PRX" "REGPLOT" "SKPCHR" "SKPCOL" "STKPLOT"
                    "FMT"
                    ;; MASS Storage
                    "CREATE" "DIR" "NEWM" "PURGE" "READA" "READK" 
                    "READP" "READR" "READRX" "READS" "READSUB" "RENAME"
                    "SEC" "SEEKR" "UNSEC" "VERIFY" "WRTA" "WRTK" "WRTP"
                    "WRTPV" "WRTR" "WRTRX" "WRTS" "ZERO"
         ))
         ;; HEPAX
         (hepax '("HEPAX" "HFS" "HWM" "HSAVE"
         ))
         ;; Flow control and labels
         (control '("LBL" "GTO" 
         "XEQ IND" 
         "XEQ" "RTN" "STOP" 
         "END" "AVIEW" "VIEW" 
         "AON"" ADV" "AOFF" "PSE" "PROMPT" "ASN" 
         "BEEP" "CLD" "CLP" "CLs" "COPY" 
         "D-R" "DEC" "DEG" "DEL" "ENG" "FIX" "GRAD" "OCT" "OFF" 
         "ON" "PACK"  "RAD" "SDEV" "SCI" "s+" "s-" "sREG" 
         "SIZE" "SST" "TONE"
         ))
         ;;
         ;; Register and Flag operation
         ;;
         (registers '("STO" "STO IND" "RCL" "RCL IND" 
         "ST+" "ST+ IND" "ST-" "ST- IND" "ST*" "ST* IND" 
         "ST/ " "ST/ IND" "CLRG" "CLST" "ASTO" 
         "CLX" "CLA" "ENTER" "ARCL" "ASHF" "R^" "LASTX" 
         "X<>" "X<>Y" "RDN" ))
         ;;
         ;; Stacks registers
;;         (stack-regs '("X" "Y" "Z" "T" "L" "M" "N" "O"))
         ;;
         ;; Flags
         (flags '("SF" "CF"))
         ;;
         ;; Conditional tests (FOCAL "Skip if False" logic)
         (tests '("X=0?" "X=Y?" "X<0?" "X<=0?" "X>0?" "X>=0?" 
         "X<>0?" "X#Y?" "X<Y?" "X<=Y?" "X>Y?" "X>=Y?" 
         "DSE" "ISG" "FS?" "FC?" "FS?C" "FC?C")))

    `(
;;      ("\\b\\([0-9]+\\)\\b" . font-lock-constant-face)
;;      (,(regexp-opt control 'words) . font-lock-keyword-face)
      (,(regexp-opt control 'symbols) . font-lock-keyword-face)
;;      (,(regexp-opt operators 'words) . font-lock-builtin-face)
      (,(regexp-opt operators 'symbols) . font-lock-builtin-face)
;;      (,(regexp-opt registers 'words) . font-lock-variable-name-face)
      (,(regexp-opt registers 'symbols) . font-lock-variable-name-face)
;;      (,(regexp-opt stack-regs 'symbols) . 'hp41-register-face)
;;      (,(regexp-opt flags 'words) . font-lock-type-face)
      (,(regexp-opt flags 'words) . 'hp41-flags-face)
;;      (,(regexp-opt tests 'words) . font-lock-warning-face)
      (,(regexp-opt tests 'symbols) . font-lock-warning-face)
      (,(regexp-opt 41cx 'words) . font-lock-function-name-face)
      (,(regexp-opt extfct 'words) . font-lock-function-name-face)
      (,(regexp-opt timemod 'words) . font-lock-function-name-face)
      (,(regexp-opt ilmod 'words) . font-lock-function-name-face)
      (,(regexp-opt hepax 'words) . font-lock-function-name-face)
      ;; Highlight numeric labels (e.g., LBL 01) or line numbers
      ("\\b\\([0-9]+\\)\\b" . font-lock-constant-face)
      ;; Highlight ALPHA strings in quotes
      ("\"\\([^\"]*\\)\"" . font-lock-string-face)))
  "Syntax highlighting rules for HP-41 RPN.")
;;
  (define-derived-mode hp41-mode prog-mode "HP-41"
  "Major mode for editing HP-41 RPN programs."
  (setq font-lock-defaults '(hp41-font-lock-keywords))
  ;; Define comment syntax
  ;; using semicolon as a common convention for FOCAL text files
  (setq-local comment-start "; ")
  (modify-syntax-entry ?\; "<" hp41-mode-syntax-table)
  (modify-syntax-entry ?\n ">" hp41-mode-syntax-table)
;; Ensure ^ is treated as a symbol constituent so X^2 is matched as one unit
 ;; CRITICAL: Treat special chars and digits as symbol constituents
  ;; This prevents X=0? from being broken into pieces.
  (modify-syntax-entry ?^ "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?? "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?= "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?< "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?> "_" hp41-mode-syntax-table)
  ;; Treat all digits as symbol constituents so they can be part of an instruction
  (modify-syntax-entry ?0 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?1 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?2 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?3 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?4 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?5 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?6 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?7 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?8 "_" hp41-mode-syntax-table)
  (modify-syntax-entry ?9 "_" hp41-mode-syntax-table)
  )

;; Automatically trigger for .rpn or .focal or .hp41 files
(add-to-list 'auto-mode-alist '("\\.\\(rpn\\|focal\\|hp41\\)\\'" . hp41-mode))

;; automatic showing documentation of word when mouse pass over it
;; ChatGPT use with
;;   uploading the whole code file.. then new 
;;   ask 1: within this project which is for syntax highlighting 
;;          of HP41 programs edited with emacs, how to show an 
;;          explanation of a word when the mouse cursor pass 
;;          over it: passing over the word "ACOS" would then 
;;          show the comment "Inverse Cosine using current 
;;          trigonometry mode"
;; commands 
;; https://www.thimet.de/CalcCollection/Calculators/HP-41/HP-41-Commands.pdf
;; use \n for multiple lines or just text on a new line
(defvar hp41-command-docs '(
  ("+" . "Add Y + X then result into X 
Z copied into Y; T copied into Z; old X now in L")  
  ("-" . "Substract Y - X then result into X 
Z copied into Y; T copied into Z; old X now in L")  
  ("*" . "Multiply Y * X then result into X \nZ copied into Y; T copied into Z; old X now in L")  
  ("/" . "Divide Y / X then result into X
Z copied into Y; T copied into Z; old X now in L")  
  ("1/X" . "Reciprocal value")  
  ("10^X" . "Exponential function base 10")  
  ("ABS" . "Absolute (positive) value of X")
  ("ACOS" . "Inverse Cosine using current trigonometry mode")
  ("AOFF" . "ALPHA mode off")  
  ("AON" . "ALPHA modem on. Using the SHIFT key various special keys and functions \ncan be accessed. See on the back of the calculator. \nThe ALPHA register can hold up to 24 characters. \nPRGM mode: A program line can only hold at most 15 characters. To put a \nlonger string into the ALPHA register use two program lines and start the \nsecond one with > SHIFT K < which is the APPEND command")
  ("ARCL" . "Append the value of the data register nn to the ALPHA register. A data \nregister or a stack register can hold at most 6 characters. Note that if ALPHA \ndata is stored in a data or stack register the ALPHA mode of the data will be \npreserved. An error occurs if a numerical function is executed on ALPHA data. \nSee RCL for indirect addressing modes.")  
  ("ASHF" . "Shift ALPHA register 6 characters to the left. Left 6 characters are lost")  
  ("ASIN" . "Inverse Sine using current trigonometry mode")
  ("ASN" . "NOT PROGRAMMABLE \nAssign a function or program to an arbitrary key for use in USER mode: \nASN ALPHA <func name/program name> ALPHA <key> Or \nASN ALPHA <func name/program name> ALPHA SHIFT <key> in which \ncase SHIFT <key> executes the command. \nTo undo the assignment: ASN ALPHA ALPHA [SHIFT] <key> \nSee also command LBL for top-row auto-execution")
  ("ASTO" . "Store leftmost 6 characters of the ALPHA register in data register nn. See RCL for indirect addressing modes. See ARCL for more information on ALPHA data")  
  ("ATAN" . "Inverse Tangent using current trigonometry mode")
  ("AVIEW" . "Display the ALPHA register ")  
  ("BEEP" . "Play a fixed short melody")  
  ("BST" . "NOT PROGRAMMABLE.
PRGM mode: Go to previous program step.
RUN mode: Go to previous program step but do not execute any commands")  
  ("CAT" . "NOT PROGRAMMABLE
CATALOG list functions:
CAT 1: Global program labels. Global programs are separated by END
instructions. Press PRGM to edit the currently listed program
CAT 2: Functions in expansion modules
CAT 3: Built-in functions
CAT 0, 4-9: Same as CAT 3
R/S halts the listing, SST shows next entry, BST shows previous entry.
See RCL for indirect addressing modes")  
;;
;;  ("CF" . "Clear flag nn. See RCL for indirect addressing modes. Flags are: 
;;00-10: General purpose flags where flags 0-3 are shown in the LCD display. Can be set/reset by the user 
;;11-29: Special purpose flags. Can be set/reset by the user. Those sometimes have a special meaning: 
;;11: Automatic Execution Flag. 
;;    If set the HP-41C automatically begins executing the current program whenever the calculators turned on 
;;14: Card Reader Overwrite Flag. When set, flag 14 allows you to overwrite write-protected cards with the optional card reader 
;;21: Printer Enable Flag. Printing is enabled when this flag is set 
;;22, 23: Data Entry Flags. These two flags detect keyboard input. 
;;        The calculator sets flag 22 when numeric data is entered from the keyboard. 
;;        flag 23 set when alpha data is entered. 
;;        Both flags are cleared each time calculator is turned on 
;;24, 25: Range Error And Error Ignore Flags. 
;;        That these flags control how the HP-41C reacts to range errors and operating errors. 
;;        If flag 24 is set range errors are ignored and numbers such as 9.999999999x1099 are returned in place of errors. 
;;        Flag 24 remains set until you clear it. If flag 25 set other errors are ignored. 
;;        Flag 25 is cleared each time an error occurs 
;;26: Audio Enable Flag. When set tones are produced
;;27: User Mode Flag. This flag is used to place the calculator in user mode
;;28, 29: Number Display Control Flags. Flag 28 controls the radix and
;;        separator marks. It may be set for American or European styles.
;;        When flag 29 is set groups of three digits are separated with commas or points depending on the setting of flag 28.
;;30-55: System flags. Can only be tested:
;;30: Catalog Flag. For internal use
;;31-35: Peripheral Flags. These flags are used internally for the operation of certain peripherals
;;36-39: Number Of Digits. These flags are used internally to control the number of digits displayed
;;40, 41: Display Format Flags. These flags control the display mode
;;42, 43: Trigonometry Mode Flags. When flag 42 is set the calculator is in GRAD mode. 
;;        When flag 43 a set the calculator is in RAD mode
;;44: Continuous On Flag. If flag 44 is on the HP-41C will stay on indefinitely. 
;;    If it is clear the calculator will turn off after 10 minutes of inactivity
;;45: System Data Entry Flag. Used internally and always tests clear
;;46: Partial Key Sequence. Used internally and always tests clear
;;47: Shift Set Flag. Used internally and always tests clear
;;48: Alpha Mode Flag. When the HP-41C is in alpha mode flag 48 is set, otherwise flag 48 is clear
;;49: Low Battery Flag. When this flag is set battery power is low. 
;;    The BAT annunciator will also show in the display when this flag is set
;;50: Message Flag. If set, the display contains some message (not the Alpha or X register)
;;51: SST Flag. Used internally and always tests clear
;;52: PRGM Mode Flag. Used internally and always tests clear
;;53: I/O Flag. When set, a peripheral extension is ready for I/O. Otherwise device is not ready for I/O
;;54: Pause Flag. When set a PSE (pause) instruction in a program is in progress
;;55: Printer Existence Flag. When set, an HP-41C printer is attached to the
;;calculator.")  
;;
  ("CHS" . "Change sign of X")  
  ("CLA" . "Clear ALPHA register")  
  ("CLD" . "Clear display and the displayed register (either X or ALPHA)")  
  ("CLP" . "PROGRAMMABLE ??
CLP ALPHA <prg name> ALPHA deletes the specified program
CLP ALPHA ALPHA deletes the current program")  
  ("CLRG" . "Clear all data registers")  
  ("CLs" . "Clear statistics register. See ΣREG")
  ("XXXX" . "MORE TO COME")
  ("X>Y?" . "Check whether X is bigger than Y and other comparison operations.
PRGM mode: If the condition is true the next program step is executed, otherwise it is skipped.
RUN mode: The test result is displayed i.e YES or NO")
  ("X<>" . "Swap X register with data register nn. See RCL for indirect addressing modes")  
  ("X<>Y" . "Swap X and Y register")  
  ("XEQ" . "Execute a built-in function or user program. A maximum of 6 user-subroutines
can be stacked. Ie. > XEQ ALPHA MEAN ALPHA < calculates the statistical
mean value. See RCL for indirect addressing modes")  
  ("X^2" . "Square of X; old X into L; no other registers touched")  
  ("Y^X" . "Y to the power of X. Y may be negative if X is integer")
  ))
  
(defun hp41--regexp-escape (s)
  "Escape S for use in a regular expression."
  (regexp-quote s))
(defun hp41--token-regexp (token)
  (concat
   "\\(?:^\\|[ \t]\\)"              ; left boundary
   "\\(" (hp41--regexp-escape token) "\\)"
   "\\(?:$\\|[ \t]\\)"))            ; right boundary
(defun hp41--font-lock-token (token doc)
  `(,(hp41--token-regexp token)
    (1 (progn
         (add-text-properties
          (match-beginning 1)
          (match-end 1)
          '(help-echo ,doc))
         'font-lock-builtin-face))))

(font-lock-add-keywords
 'hp41-mode
 (mapcar (lambda (entry)
           (hp41--font-lock-token (car entry) (cdr entry)))
         hp41-command-docs))


(provide 'hp41-mode)
