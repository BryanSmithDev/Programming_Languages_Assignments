#!/usr/bin/python
import sys

##########################################################
# CSC 4200-01 - Programming Languages
# Name: Bryan Smith
# Date: 2/21/14
# Description: Print bank statment based on data read from
#              file
# Paramaters:
#   fileLoc - Path to the file to read.
##########################################################

#Class that represents a users bank account
class Account:
    ID=-1
    initialBalance=0
    balance=0
    transactions=[]
    numbOfOverdrafts=0
    overdraftedLast=False
    overdraftCharge = 10.0

    def __init__(self, ID, balance, odc=10.0):
        self.ID = ID
        self.balance = balance
        self.initialBalance = balance
        self.numbOfOverdrafts = 0
        self.overdraftCharge = odc
        self.overdraftedLast = False

    #Calculates the final balance and any overdrafts
    def calculateBalance(self):
        self.balance=self.initialBalance
        for t in self.transactions:
            if (isinstance(t,Deposit)):
                self.balance+=t.getAmount()
            else:
                self.balance-=t.getAmount()
            if (self.balance < 0 and self.overdraftedLast==False):
                self.numbOfOverdrafts+=1
                self.balance-=self.overdraftCharge
                self.overdraftedLast=True
            elif(self.balance >= 0 and self.overdraftedLast==True):
                self.overdraftedLast=False

    #Adds a transaction to the account
    def addTransaction(self,t):
        self.transactions.append(t)

    #Removes a transaction from the account  
    def removeTransaction(self,t):
        self.transactions.remove(t)

    #Parses data from a string into data to load into the account
    def parseToAccount(self,lineList):
        try:
            self.ID=lineList[0].strip().split(":")[1].strip()
            self.initialBalance=float(lineList[1].strip().split(":")[1])
            self.balance=self.initialBalance
            for i in range(2,len(lineList)):
                tmpList=lineList[i].strip().split(":")
                if (tmpList[0].lower().strip().startswith("w")):
                    self.addTransaction(Withdrawal(tmpList[1].strip(),float(tmpList[2].strip())))
                else:
                    self.addTransaction(Deposit(tmpList[1].strip(),float(tmpList[2].strip())))
        except:
            print("Error: Could not parse account.")
            sys.exit(2)

    #Print withdrawal summary
    def printWithdrawals(self):
        totalWithdrawalAmount=0.0
        tmpBalance=self.initialBalance
        isFirstListed=True
        print("Summary of Withdrawals:	 amount	        Running Balance")
        print("-------------------------------------------------------")
        for t in self.transactions:
            if (isinstance(t,Deposit)):
                print("--deposit(see below)")
                tmpBalance+=t.getAmount()
            else:
                t.printTransaction(False,-isFirstListed)
                isFirstListed=False
                totalWithdrawalAmount+=t.getAmount()
                if(tmpBalance <0):
                    self.overdraftedLast=True
                else:
                    self.overdraftedLast=False
                tmpBalance-=t.getAmount()
                if(tmpBalance >0):
                   print("{0:>24}".format(tmpBalance))
                elif (tmpBalance <0 and self.overdraftedLast == False):
                    sys.stdout.write("{0:>24}".format("( {:.2f})".format(-tmpBalance)))
                    sys.stdout.write("*\n")
                    
        print("-------------------------------------------------------")
        print("{0:<21} {1:>9}".format("Total Withdrawals","${:.2f}".format(totalWithdrawalAmount)))

    #Print Deposits summary
    def printDeposits(self):
        totalDepositAmount=0.0
        isFirstListed=True
        print("\nSummary of Deposits:")
        print("-------------------------------")
        for t in self.transactions:
            if (isinstance(t,Deposit)):
                t.printTransaction(True,-isFirstListed)
                isFirstListed=False
                totalDepositAmount+=t.getAmount()
                    
        print("\n-------------------------------")
        print("{0:<16} {1:>14}".format("Total Deposits","${:.2f}".format(totalDepositAmount)))

    #Print the whole bank statement
    def __str__( self ):
        print("Statement for Account: %s\n" %(self.ID))
        print("Beginning Balance: $%.2d \n" %(self.initialBalance))
        self.printWithdrawals()
        self.printDeposits()

        if (self.numbOfOverdrafts>0):
            print("\n*Overdraft Fees")
            print("--------------")
            for i in range(self.numbOfOverdrafts):
                print("$%.2d"%(self.overdraftCharge))
            print("--------------")
        if (self.balance <0):
            print("{0:<16} {1:>14}".format("\nEnding Balance:","( ${:.2f})".format(-self.balance)))
        else:
            print("{0:<16} {1:>14}".format("\nEnding Balance:","${:.2f}".format(self.balance)))
        return ""
    
#Class that represents a bank transaction
class Transaction:
    source = "Default Source"
    amount = 0.0

    def __init__(self, s, a):
        self.source = s;
        self.amount = a;

    def printTransaction(self,newline, cur):
        if (newline and cur):
            sys.stdout.write("{0:<21} {1:>9}".format(self.source," ${:.2f}\n".format(self.amount)))
        elif(cur):
            sys.stdout.write("{0:<21} {1:>9}".format(self.source,"${:.2f}".format(self.amount)))
        else:
            sys.stdout.write("{0:<21} {1:>9}".format(self.source,"{:.2f}".format(self.amount)))

    def getAmount(self):
        return self.amount

#Child class that represents a withdrawal transaction
class Withdrawal(Transaction):
        pass

#Child class that represents a deposit transaction
class Deposit(Transaction):
        pass


#Reads in a file returning the string of what was read.
def readFile(fileLoc):
    try:
        content = []
        with open(fileLoc) as f:
            content = f.readlines()
        return content
    except:
        print("Error Reading file. Does it exist?")
        sys.exit(2)

#If there is a command line argument, use it as the input file path
if (len(sys.argv)>1):
    fileLoc=str(sys.argv[1])
else:
    fileLoc="TestFile.txt"

#Create the bank account, parse the file to load in the data, calculate and print.
user = Account(-1,0.0)
user.parseToAccount(readFile(fileLoc))
user.calculateBalance()
print user

raw_input("\n\nPress the enter key to exit.") #Wait on user so data is displayed
