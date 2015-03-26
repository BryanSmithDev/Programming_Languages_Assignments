' CSC 4200-01 - Programming Languages
' Name: Bryan Smith
' Date: 4/13/14
' Description: Bank report in BASIC (FreeBASIC Compiler)
#include "string.bi"
#include "file.bi"

Type Transaction
    transType as String * 1
    transName as String
    transAmount as Double
End Type

Sub Split (ByVal tmpString As String,parseData() as String)
    dim position as integer
    position = 0
    while not InStr(tmpString, ":") = 0
        position+=1
        redim preserve parseData(position) as String
        parseData(position) = Mid(tmpString,1,InStr(tmpString, ":")-1)
        tmpString=Trim(Mid(tmpString,InStr(tmpString, ":")+1,Len(tmpString)))
        if InStr(tmpString, ":") = 0 then
            position+=1
            redim preserve parseData(position) as String
            parseData(position) = tmpString
        end if
    wend
End Sub

if FileExists ("account.txt") then
    dim as integer n=0
    dim as String lines()
    open "account.txt" for input as #1
    while not eof(1)
        n+=1
        redim preserve lines(n) as String
        line input #1,lines(n)
    wend
    close #1


    dim lineParse() as String
    dim transactions() as Transaction
    dim balance as Double
    balance = 0
    dim totalTransactions as Double
    totalTransactions = 0
    dim totalDeposits as Double
    totalDeposits = 0
    dim overdraftAmount as Double
    overdraftAmount = 10.00
    dim overDrafted as byte
    overdrafted=0
    dim dollarSign as String * 1
    dollarSign="$"
    dim i as integer
    dim x as integer
    dim position as integer
    position = 0
    for i = 1 to UBound(lines)
        Split(lines(i),lineParse())
        if UBound(lineParse) <= 2 then
            if i = 1 then print"Statement for Account: " + lineParse(2) end if
            if i = 2 then
                print"Beginning Balance: $" + lineParse(2)
                balance=Cdbl(lineParse(2))
            end if
            print ""
        else
            dim tmpTrans as Transaction
            tmpTrans.transType = lineParse(1)
            tmpTrans.transName = lineParse(2)
            tmpTrans.transAmount = Val(lineParse(3))
            position+=1
            redim preserve transactions(position) as Transaction
            transactions(position) = tmpTrans
        end if
    next i

    print "Summary of Withdrawals:	 amount		Running Balance"
    print "-------------------------------------------------------"
    for i = 1 to UBound(transactions)
        if (UCase(transactions(i).transType) = "W") then
            balance-=Cdbl(transactions(i).transAmount)
            totalTransactions+=Cdbl(transactions(i).transAmount)
            dim buff as String
            dim buff2 as String
            dim buff3 as String
            buff = transactions(i).transName
            buff2 = Space((31-Len(transactions(i).transName)))
            Lset buff, transactions(i).transName
            Rset buff2, dollarSign+Str(Format(transactions(i).transAmount,"###0.00"))
            if Sgn(balance) = -1 then
                overdrafted = 1
                buff3 = Space(26)
                Rset buff3, Str(Format(abs(balance),"( ###0.00)*"))  
            else
                buff3 = Space(24)
                Rset buff3, Str(Format(balance,"###0.00"))
            end if
            
            dollarSign=""
            print  buff+buff2+buff3
        else
            print "--deposit(see below)"
            balance+=Cdbl(transactions(i).transAmount)
        end if
    next i
    print "-------------------------------------------------------"
    dim buff as String
    buff = Space(14)
    Rset buff, "$"+Str(Format(totalTransactions,"###0.00"))
    print "Total Withdrawals"+buff

    dollarSign="$"
    print ""
    print "Summary of Deposits:"
    print "-------------------------------"
    for i = 1 to UBound(transactions)
        if (UCase(transactions(i).transType) = "D") then
            totalDeposits+=Cdbl(transactions(i).transAmount)
            dim buff as String
            dim buff2 as String
            buff = transactions(i).transName
            buff2 = Space((31-Len(transactions(i).transName)))
            Lset buff, transactions(i).transName
            Rset buff2, dollarSign+Str(Format(transactions(i).transAmount,"###0.00"))
            dollarSign=""
            print  buff+buff2
        end if
    next i
    print "-------------------------------"
    buff = Space(17)
    Rset buff, "$"+Str(Format(totalDeposits,"###0.00"))
    print "Total Deposits"+buff
    print ""

    if not overdrafted = 0 then
        print "*Overdraft Fees"
        print "--------------"
        print "$"+Str(Format(overdraftAmount,"###0.00"))
        print "--------------"
        print ""
        balance-=overdraftAmount
    end if

    buff = Space(16)
    Rset buff, "$"+Str(Format(balance,"###0.00"))
    print "Ending Balance:"+buff
else
    print "Cannot find account.txt file."
end if
sleep
