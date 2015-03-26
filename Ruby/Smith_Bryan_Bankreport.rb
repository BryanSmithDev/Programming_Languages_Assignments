#!/usr/bin/ruby
############################################
## CSC 4200-01 - Programming Languages
## Name: Bryan Smith
## Date: 3/21/14
## Description: Print bank statement based on data read from file
############################################


##################################
#   Transaction Classes
##################################
class Transaction

    def initialize(source, amount)
        @source = source
        @amount = amount
    end
    
    def getSource();@source;end
    def getAmount();@amount.to_f;end
    
    def print(newline,cur)
		if (cur)
            printf("%-21s %9s",getSource(),sprintf("$%.2f",getAmount()))
        else
            printf("%-21s %9.2f",getSource(),getAmount())
        end
        
        if (newline);puts "\n";end
    end
            
end

class Withdrawal < Transaction;end  #Withdrawal class
class Deposit < Transaction;end     #Deposit class

##################################
#   Account Class
##################################
class Account
    def initialize(i, iB,odc)
        @id=i
        @balance=iB.to_f
        @initialBalance=iB.to_f
        @overdraftCharge=odc.to_f
        @transactions=Array.new
        @numbOfOverdrafts=0
        @overdraftedLast=false
    end
    
    def getTransactions();@transactions;end;
    
    def calculateBalance()
        @balance = @initialBalance.to_f
        @transactions.each do |t|
            if (t.instance_of?(Deposit))
                @balance+=t.getAmount().to_f
            else
                @balance-=t.getAmount().to_f
            end
            if (@balance<0 and !@overdraftedLast)
                @numbOfOverdrafts+=1
                @overdraftedLast=true
            end
            if (@balance >=0 and @overdraftedLast); @overdraftedLast=false; end;
        end
    end
    
    def addTransaction(t);@transactions << t;end;
    
    def parseToAccount(s)
        begin
            @idString=s[0].split(':')
            if(@idString[0].start_with?("acc"));@id = @idString[1].strip();
            else; raise "Cannot parse Account number.";end;
            @iBString=s[1].split(':')
            if(@iBString[0].start_with?("beginning"))
                @initialBalance = @iBString[1].strip()
                @balanace = @initialBalance
            else; raise "Cannot parse initial balance.";end;
            (2..s.size-1).each do |i|
                splitString = s[i].split(':')
                if (splitString[0].to_s[0].downcase! == 'd')
                    addTransaction(Deposit.new(splitString[1].strip(),splitString[2].strip()))
                elsif (splitString[0].to_s[0].downcase! == 'w')
                    addTransaction(Withdrawal.new(splitString[1].strip(),splitString[2].strip()))
                else
                    raise "Could not parse transactions."
                end
            end
            calculateBalance()
            self
        rescue
            raise "Error parsing data."
            abort
        end
    end

    def printWithdrawals()
        @totalWithdrawalAmount = 0.0
        @tmpBalance = @initialBalance.to_f
        @isFirstListed=false
        puts "Summary of Withdrawals:  amount	        Running Balance\n"
        puts "-------------------------------------------------------\n"
        @transactions.each do |t|
            if (t.instance_of?(Deposit))
                puts "--deposit(see below)\n"
                @tmpBalance+=t.getAmount().to_f
            elsif (t.instance_of?(Withdrawal))
                t.print(false,!@isFirstListed)
                @isFirstListed=true
                @totalWithdrawalAmount+= t.getAmount().to_f
                if(@tmpBalance <0.0);@overdraftedLast=true;
                else; @overdraftedLast=false;end;
                @tmpBalance-=t.getAmount().to_f
                if(@tmpBalance<0 and !@overdraftedLast)
                    printf("%26s\n",sprintf("( %.2f)*",-@tmpBalance));
                else
                    printf("%24s\n",sprintf("%.2f",@tmpBalance));
                end
            end

        end
         puts "-------------------------------------------------------\n"
         printf("Total Withdrawals %13s\n",sprintf("$%.2f",@totalWithdrawalAmount))
    end

    def printDeposits()
        @totalDepositAmount = 0.0
        @isFirstListed=false
        puts "\nSummary of Deposits:\n"
        puts "-------------------------------\n"
        @transactions.each do |t|
            if (t.instance_of?(Deposit))
                t.print(true,!@isFirstListed)
                @isFirstListed=true
                @totalDepositAmount+= t.getAmount().to_f
            end
        end
        puts "-------------------------------\n"
        printf("Total Deposits %16s\n",sprintf("$%.2f",@totalDepositAmount))
    end

    def to_s
        print("Statement for Account: #@id\n\n")
        print("Beginning Balance: $#@initialBalance\n\n")
        printWithdrawals()
        printDeposits()
        if (@numbOfOverdrafts>0)
            print("\n*Overdraft Fees\n")
            print("--------------\n")
            i=0
            while i < @numbOfOverdrafts do
                printf("$%.2f\n",@overdraftCharge)
                @balance-=@overdraftCharge
                i=i+1
            end
            print("--------------\n")
        end
        if (@balance <0)
            s=sprintf("\nEnding Balance: %15s\n",sprintf("( %.2f)",-@balance));
        else
            s=sprintf("\nEnding Balance: %15s\n",sprintf("$%.2f",@balance));
        end
        s
    end

end

#Read in the account data file
def readFile(fileLoc)
    begin
        arr = IO.readlines(fileLoc);arr
    rescue
        puts "Cannot open account file. Does it exist?"
        abort
    end
end

##################################
#   Execute
##################################
@account = Account.new(123,0.0,10.0)
puts @account.parseToAccount(readFile("account.txt"))
