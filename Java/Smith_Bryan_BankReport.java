import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * 
 * CSC 4200-01 - Programming Languages
 * @author Bryan Smith
 * @date 2/26/14
 * @description Print bank statment based on data read from file
 * 
 */
public class Smith_Bryan_BankReport {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//If there is a command line argument, use it as the input file path
        String arg;
        if (args.length > 0) arg = args[0]; else arg = "TestData.txt";

        //Create the bank account, parse the file to load in the data, calculate and print.
        Account newAccount = new Account();
        newAccount.parseStringToAccount(readFile(arg));
        newAccount.calculateBalance();
        newAccount.printStatment();


	}
	
    //Reads in a file returning the string of what was read.
    private static String readFile(String fileLoc)
    {
    	String s = "";
    	FileInputStream fis = null;
		try {
			BufferedReader in = new BufferedReader(new FileReader(fileLoc));

			while (in.ready()) {
			  s = s + in.readLine()+":";
			}
			in.close();
 
		} catch (IOException e) {
			System.out.println("Error Reading File. Does it exist?");
			System.exit(-1);
		}
    	return s;
    }
	
	
	private static class Account {
	    int ID=-1;
	    double initialBalance=0;
	    double balance=0;
	    List<Transaction> transactions = new ArrayList<>();
	    int numbOfOverdrafts=0;
	    boolean overdraftedLast=false;
	    double overdraftCharge = 10.0;
	    
		public Account() {
			super();
		}

		/**
		 * @param id
		 * @param balance
		 * @param overdraftCharge
		 */
		public Account(int id, double balance, double overdraftCharge) {
			super();
			ID = id;
			this.balance = balance;
			this.overdraftCharge = overdraftCharge;
		}
		
        //Calculates the final balance and any overdrafts
        public void calculateBalance()
        {
        	balance = initialBalance;
            for(Transaction t : transactions)
            {
                if (t instanceof Deposit){
                    balance += t.amount;
                }
                else
                {
                    balance -= t.amount;
                }
                if (balance < 0 && !overdraftedLast) {
                	numbOfOverdrafts++;
                    overdraftedLast=true;
                }
                else if (balance >= 0 && overdraftedLast) { overdraftedLast = false; }
            }
        }
	    
		//Adds a transaction to the account
        public void addTransaction(Transaction t){
            transactions.add(t);
        }

        //Removes a transaction from the account
        public void removeTransaction(Transaction t)
        {
        	transactions.remove(t);
        }
        
        //Parses data from a string into data to load into the account
        public void parseStringToAccount(String s)
        {
            try
            {
                String[] splitString = s.trim().split(":");
                if (splitString[0].toString().trim().toLowerCase().startsWith("acc"))
                {
                    ID = Integer.parseInt((splitString[1].toString().trim()));
                }
                else { throw new Exception("Could not parse account number."); }
                if (splitString[2].toString().trim().toLowerCase().startsWith("beg"))
                {
                    initialBalance = Double.parseDouble(splitString[3].toString().trim());
                    balance = initialBalance;
                }
                else { throw new Exception("Could not parse initial balance."); }
                for (int i = 4; i < splitString.length; i = i + 3)
                {
                    if (splitString[i].toString().trim().toLowerCase().startsWith("w")) addTransaction(new Withdrawal(splitString[i + 1].trim(), Double.parseDouble(splitString[i + 2].trim())));
                    else if (splitString[i].toString().trim().toLowerCase().startsWith("d")) addTransaction(new Deposit(splitString[i + 1].trim(), Double.parseDouble(splitString[i + 2].trim())));
                    else throw new Exception("Failed to parse transactions.");
                }
            } catch (Exception e) {
                System.out.println("Error: "+e.getMessage());
				System.exit(-1);
            }
        }
        
        //Print withdrawal summary
        protected void printWithdrawals()
        {
            double totalWithdrawalAmount = 0.0;
            double tmpBalance = initialBalance;
            boolean isFirstListed = false;
            System.out.println("Summary of Withdrawals:	 amount	        Running Balance");
            System.out.println("-------------------------------------------------------");
            for (Transaction t : transactions)
            {
                if (t instanceof Deposit)
                {
                    System.out.println("--deposit(see below)");
                    tmpBalance += t.amount;
                }
                else
                {
                    t.print(false,!isFirstListed);
                    isFirstListed = true;
                    totalWithdrawalAmount += t.amount;
                    if (tmpBalance < 0) overdraftedLast = true; else overdraftedLast = false;
                    tmpBalance -= t.amount;
                    if (tmpBalance < 0 && overdraftedLast==false) {
                    	 System.out.println(String.format("%25s",String.format("( %.2f)*",-tmpBalance)));
                    } else {
                    	System.out.println(String.format("%24s",String.format("%.2f",tmpBalance)));
                    }
                    
                }
            }
            System.out.println("-------------------------------------------------------");
            System.out.println(String.format("Total Withdrawals %5s$%.2f","",totalWithdrawalAmount));
        }
        
        //Print Deposits summary
        protected void printDeposits()
        {
        	 double totalDepositAmount = 0.0;
             boolean isFirstListed = false;
            System.out.println("\nSummary of Deposits:");
            System.out.println("-------------------------------");
            for (Transaction t : transactions)
            {
                if (t instanceof Deposit)
                {
                    t.print(true,!isFirstListed);
                    isFirstListed = true;
                    totalDepositAmount += t.amount;
                }
            }
            System.out.println("-------------------------------");
            System.out.println(String.format("Total Deposits %8s$%.2f","",totalDepositAmount));
        }
        
        //Print the whole bank statement
        public void printStatment()
        {
     
        	System.out.println(String.format("Statement for Account: %d\n", ID));
        	System.out.println(String.format("Beginning Balance: $%.2f\n", initialBalance));
            
        	printWithdrawals();
        	printDeposits();
        	
            if (numbOfOverdrafts>0)
            {
            	 System.out.println("\n*Overdraft Fees");
            	 System.out.println("--------------");
                for (int i = 0; i < numbOfOverdrafts;i++)
                {
                	 System.out.println(String.format("$%.2f", overdraftCharge));
                    balance -= overdraftCharge;
                }
                System.out.println("--------------");
            }
            if (balance < 0) System.out.println(String.format("\nEnding Balance: %7s( $%.2f)","",-balance));
            else System.out.println(String.format("\nEnding Balance: %7s$%.2f","",balance));
        }

	    
	}
	
	private static class Transaction {
		String source="Default Source";
		double amount=0.0;
		
		
        /**
		 * @param source
		 * @param amount
		 */
		public Transaction(String source, double amount) {
			this.source = source;
			this.amount = amount;
		}


		public void print(boolean newline, boolean cur) {
           System.out.print(String.format("%-15s %15s",source,String.format((cur ? "$%.2f" : "%.2f"),amount)));
           if (newline)   System.out.println();
        }
	}
	
	private static class Withdrawal extends Transaction {

		public Withdrawal(String source, double amount) {
			super(source, amount);
			// TODO Auto-generated constructor stub
		}
		
	}
	
	private static class Deposit extends Transaction {

		public Deposit(String source, double amount) {
			super(source, amount);
			// TODO Auto-generated constructor stub
		}
		
	}

}
