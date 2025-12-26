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
;; constructed with the help of GEMINI
;; similar to this for vim https://github.com/isene/hp-41_vim
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
;;   emacs -debug-init /home/userXYZ/ELPER.hp41
;; or
;;   emacs  -q --load '/home/userXYZ/.emacs.d/hp41-mode.el' /home/userXYZ/ELPER.hp41 
;; 
;; TODO:
;; [ ] test test test..
;; [ ] more module function list
;; [ ] take non programmable fct out
;; [ ] link it to cc41 (like with prolog-swipl or riscv-spike or forth-gforth)
;; [ ] case unsensitive
;; [ ] ..
;; [ ] ..
;; [ ] ..
;; [ ] ..
;;
;; change log
;; 2025.12.24 Creation
;; 2025.12.26 Upload Github
;;
;; 1. Define a custom face for HP-41 specific registers
(defface hp41-register-face
  '((t :inherit font-lock-variable-name-face :inverse-video t))
  "Face for HP-41 stack registers (X, Y, Z, T, L) and alpha registers (M, N, O)."
  :group 'hp41)
;;
;; 2. Define a custom face for HP-41 flags
(defface hp41-flags-face
  '((t :inherit font-lock-type-face :inverse-video t))
  "Face for flag words"
  :group 'hp41)
;;
;;
(defvar hp41-font-lock-keywords
  (let* (;; Core stack and math operations
         (operators '("+" "-" "*" "/" "1/X" "SQRT" "LOG" "LN" "EXP" "10^X" "ABS" "SIGN" "E^X"
         "E^X-1" "FACT" "LN1+X" "MEAN" "MOD" "Y^X" "CHS" "ACOS" "SIN" "COS" "TAN" "RND"  "FRC"
         "X^2" "ASIN" "ATAN" "P-R" "HMS" "HMS+" "HMS-" "HR" "INT" "PI" "R-D" "R-P"
         "%" "%CH"
         ))
         ;;
         (41cx '("CLALMA" "CLALMX" "CLRALMS" "RCLALM" "SWPT"
         ))
         ;; 82182A Time Module
         (timemod '("ATIME" "ADATE" "SETIME" "SETDATE" "CLOCK" "T+X" "CLKTD" "CLK12" 
                    "ALMCAT" "ALMNOW" "ATIME24" "CLK24" "CLKT" "CORRECT" "DATE" "DATE+"
                    "DDAYS" "DMY" "DOW" "MDY" "RCLAF" "RCLSW" "RUNSW" "SETAF" "SETSW" 
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
                    "AUTOIO" "FINDID" "INA" "IND" "INSTAT" "LISTEN"
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
         (control '("LBL" "GOTO" "XEQ" "RTN" "STOP" "END" "AVIEW" "VIEW" 
         "AON"" ADV" "AOFF" "PSE" "PROMPT" "ASN" 
         "BEEP" "BST" "CAT" "CLD" "CLP" "CLs" "COPY" 
         "D-R" "DEC" "DEG" "DEL" "ENG" "FIX" "GRAD" "OCT" "OFF" "ON" 
         "PACK"  "RAD" "SDEV" "SCI" "s+" "s-" "sREG" "SIZE" "SST" "TONE"
         ))
         ;;
         ;; Register and Flag operation
         ;;
         (registers '("STO" "STO IND" "RCL" "RCL IND" "ST+" "ST+ IND" 
         "ST-" "ST- IND" "ST*" "ST* IND" "ST/ " "ST/ IND" "CLRG" "CLST" "ASTO" 
         "CLX" "CLA" "ENTER" "ARCL" "ASHF" "R^" "LASTX" "X<>" "X<>Y" "RDN" ))
         (stack-regs '("X" "Y" "Z" "T" "L" "M" "N" "O"))
         ;;
         (flags '("SF" "CF" "FS?" "FC?" "FS?C" "FC?C"))
         ;;
         ;; Conditional tests (FOCAL "Skip if False" logic)
         (tests '("X=0?" "X=Y?" "X<0?" "X<=0?" "X>0?" "X>=0?" "X<>0?" "X#Y?" "X<Y?" "X<=Y?" "X>Y?" "X>=Y?" "DSE" "ISG" )))

    `(
;;      ("\\b\\([0-9]+\\)\\b" . font-lock-constant-face)
      (,(regexp-opt control 'words) . font-lock-keyword-face)
;;      (,(regexp-opt operators 'words) . font-lock-builtin-face)
      (,(regexp-opt operators 'symbols) . font-lock-builtin-face)
;;      (,(regexp-opt registers 'words) . font-lock-variable-name-face)
      (,(regexp-opt registers 'symbols) . font-lock-variable-name-face)
      (,(regexp-opt stack-regs 'symbols) . 'hp41-register-face)
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

;;;###autoload
  (define-derived-mode hp41-mode prog-mode "HP-41"
  "Major mode for editing HP-41 RPN programs."
  (setq font-lock-defaults '(hp41-font-lock-keywords))
  ;; Define comment syntax (using semicolon as a common convention for FOCAL text files)
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

(provide 'hp41-mode)
