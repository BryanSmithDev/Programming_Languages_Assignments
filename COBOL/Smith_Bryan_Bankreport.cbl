       IDENTIFICATION DIVISION.
       PROGRAM-ID.  BankReport.
       AUTHOR.  Bryan Smith.  
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TransFile ASSIGN TO "account.txt"
       		ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD TransFile.
       01  AccountInfo       PIC A(205).
          88 EndOfFile   VALUE HIGH-VALUES.
          
       WORKING-STORAGE SECTION.
       01 accNumb             PIC X(11).
       01 overdrafts          PIC 9 VALUE 0.
       01 overdraftAmount     PIC 99V99 VALUE 10.00.
       01 intBalance          PIC S9999V99.
       01 balance             PIC S9999V99.
       01 tmpMoneyStr         PIC -$(4)9.99.
       01 tmpMoneyInt         PIC S9999V99.
       01 transType           PIC A.
       01 transName           PIC X(21).
       01 transAmount         PIC S9999V99.
       01 totalWith           PIC S9999V99.
       01 totalDep            PIC S9999V99.
       01 runningBalPrint     PIC -$(19)9.99.
       01 runningBalPrintNeg  PIC $(5)9.99.
       01 overDraftPrint      PIC $99.99.
       01 fill              PIC A(14) VALUE SPACES.
       
       PROCEDURE DIVISION.
       Begin.
          OPEN INPUT TransFile.
          READ TransFile
             AT END SET EndOfFile TO TRUE
          END-READ.
          PERFORM 1 TIMES
             UNSTRING AccountInfo DELIMITED BY ":"
                INTO accNumb,accNumb
             READ TransFile
             END-READ
             UNSTRING AccountInfo DELIMITED BY ":"
                INTO intBalance,intBalance
             MOVE intBalance TO balance
             READ TransFile
             END-READ
          END-PERFORM.
          MOVE intBalance TO tmpMoneyStr
          DISPLAY "Statement for Account:" accNumb
          DISPLAY " " 
          DISPLAY "Beginning Balance:" tmpMoneyStr
          DISPLAY " "
          DISPLAY 
          "Summary of Withdrawals:  amount         Running Balance"
          DISPLAY 
          "-------------------------------------------------------"
          PERFORM UNTIL EndOfFile
             UNSTRING AccountInfo DELIMITED BY ":"
                INTO transType, transName, transAmount
             IF transType = 'W' THEN
               ADD transAmount TO totalWith
               SUBTRACT transAmount FROM balance
               MOVE transAmount TO tmpMoneyStr
               IF balance < 0.00 THEN
                MOVE balance TO runningBalPrintNeg
                ADD 1 TO overdrafts
                DISPLAY 
                transName SPACE tmpMoneyStr fill
                '(' runningBalPrintNeg ')*'
               ELSE
                MOVE balance TO runningBalPrint
                DISPLAY transName SPACE tmpMoneyStr runningBalPrint
               END-IF

             ELSE
               ADD transAmount TO balance
               DISPLAY "--deposit(see below)"
             END-IF
       
             READ TransFile
                AT END SET EndOfFile TO TRUE
             END-READ
          END-PERFORM.
          DISPLAY 
          "-------------------------------------------------------"
          MOVE totalWith TO tmpMoneyStr
          MOVE "Total Withdrawals" TO transName
          DISPLAY transName SPACE tmpMoneyStr
          DISPLAY " "
          DISPLAY "Summary of Deposits:"
          DISPLAY "-------------------------------"
          CLOSE TransFile.
          OPEN INPUT TransFile
          PERFORM 3 TIMES
             READ TransFile
             END-READ
          END-PERFORM
          PERFORM UNTIL EndOfFile
             UNSTRING AccountInfo DELIMITED BY ":"
                INTO transType, transName, transAmount
             IF transType = 'D' THEN
               ADD transAmount TO totalDep
               MOVE transAmount TO tmpMoneyStr
               DISPLAY transName SPACE tmpMoneyStr
             END-IF
       
             READ TransFile
                AT END SET EndOfFile TO TRUE
             END-READ
          END-PERFORM
          DISPLAY "-------------------------------"
          MOVE totalDep TO tmpMoneyStr
          MOVE "Total Deposits" TO transName
          DISPLAY transName SPACE tmpMoneyStr
          DISPLAY " ".
          
          IF overdrafts > 0 THEN
           MOVE overdraftAmount TO overdraftPrint
           DISPLAY "*Overdraft Fees"
           DISPLAY "--------------"
           DISPLAY overdraftPrint
           DISPLAY "--------------"
           DISPLAY " "
           SUBTRACT overdraftAmount FROM balance
          END-IF
          MOVE "Ending Balance:" TO transName
          MOVE balance TO tmpMoneyStr
          DISPLAY transName SPACE tmpMoneyStr
          CLOSE TransFile.
       STOP RUN.
