using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Smith_Bryan_BankReport
{
    class Smith_Bryan_BankReport
    {

        static void Main(string[] args)
        {
            //If there is a command line argument, use it as the input file path
            string arg;
            if (args.Length > 0) arg = args[0]; else arg = "TestInput.txt";

            //Create the bank account, parse the file to load in the data, calculate and print.
            Account newAccount = new Account();
            newAccount.parseStringToAccount(readFile(arg));
            newAccount.calculateBalance();
            newAccount.printStatment();

            Console.ReadLine(); //Wait on user so data is displayed

        }

        //Reads in a file returning the string of what was read.
        private static string readFile(string fileLoc)
        {
            try
            {
                using (StreamReader sr = new StreamReader(fileLoc))
                {
                    String line = sr.ReadToEnd();
                    return line;
                }
            } catch  (Exception e)   {
                if (e is FileLoadException) Console.WriteLine("Error loading file. - "+e.Message);
                else Console.WriteLine("Error: File not found. - "+fileLoc+"\n"+e.Message);
                return null;
            }
        }
    }


    class Account
    {
        protected int ID { get; set; }
        protected double InitialBalance { get; set; }
        protected double Balance { get; set; }
        protected List<Transaction> Transactions { get; set; }
        protected int NumbOfOverdafts { get; set; }
        protected bool OverdraftedLast { get; set; }
        protected double OverdraftCharge { get; set; }

        public Account()
        {
            ID = 0;
            Balance = 0.0;
            InitialBalance = Balance;
            Transactions = new List<Transaction>();
            NumbOfOverdafts = 0;
            OverdraftCharge = 10.0;
            OverdraftedLast = false;
        }

        public Account(int id, double balance, double odc=10.0)
        {
            ID = id;
            Balance = balance;
            InitialBalance = balance;
            Transactions = new List<Transaction>();
            NumbOfOverdafts = 0;
            OverdraftCharge = odc;
            OverdraftedLast = false;
        }

        //Calculates the final balance and any overdrafts
        public void calculateBalance()
        {
            Balance = InitialBalance;
            foreach (Transaction t in Transactions)
            {
                if (t.GetType() == typeof(Deposit)){
                    Balance += t.Amount;
                }
                else
                {
                    Balance -= t.Amount;
                }
                if (Balance < 0 && !OverdraftedLast) {
                    NumbOfOverdafts++;
                    OverdraftedLast=true;
                }
                else if (Balance >= 0 && OverdraftedLast) { OverdraftedLast = false; }
            }
        }

        //Adds a transaction to the account
        public void addTransaction(Transaction t){
            this.Transactions.Add(t);
        }

        //Removes a transaction from the account
        public void removeTransaction(Transaction t)
        {
            this.Transactions.Remove(t);
        }

        //Parses data from a string into data to load into the account
        public void parseStringToAccount(string s)
        {
            try
            {
                string[] splitString = s.Split(new char[]{':','\n'});
                if (splitString[0].ToString().Trim().StartsWith("acc", true, null))
                {
                    ID = Convert.ToInt32(splitString[1].ToString().Trim());
                }
                else { throw new Exception("Could not parse account number."); }
                if (splitString[2].ToString().Trim().StartsWith("beg", true, null))
                {
                    InitialBalance = Convert.ToDouble(splitString[3].ToString().Trim());
                    Balance = InitialBalance;
                }
                else { throw new Exception("Could not parse initial balance."); }
                for (int i = 4; i < splitString.Length; i = i + 3)
                {
                    if (splitString[i].ToString().Trim().StartsWith("w", true, null)) addTransaction(new Withdrawal(splitString[i + 1].Trim(), Convert.ToDouble(splitString[i + 2].Trim())));
                    else if (splitString[i].ToString().Trim().StartsWith("d", true, null)) addTransaction(new Deposit(splitString[i + 1].Trim(), Convert.ToDouble(splitString[i + 2].Trim())));
                    else throw new Exception("Failed to parse transactions.");
                }
            } catch (Exception e) {
                Console.WriteLine("Error: "+e.Message);
            }
        }

        //Print withdrawal summary
        protected void printWithdrawals()
        {
            double totalWithdrawalAmount = 0.0;
            double tmpBalance = InitialBalance;
            bool isFirstListed = false;
            Console.WriteLine("Summary of Withdrawals:	 amount	        Running Balance");
            Console.WriteLine("-------------------------------------------------------");
            foreach (Transaction t in Transactions)
            {
                if (t.GetType() == typeof(Deposit))
                {
                    Console.WriteLine("--deposit(see below)");
                    tmpBalance += t.Amount;
                }
                else
                {
                    t.print(false,!isFirstListed);
                    isFirstListed = true;
                    totalWithdrawalAmount += t.Amount;
                    if (tmpBalance < 0) OverdraftedLast = true; else OverdraftedLast = false;
                    tmpBalance -= t.Amount;
                    Console.Write(String.Format("{0,24:#.00#;(#.00#)}", tmpBalance));
                    if (tmpBalance < 0 && OverdraftedLast==false) Console.Write("*");
                    Console.WriteLine();
                    

                }
            }
            Console.WriteLine("-------------------------------------------------------");
            Console.WriteLine(String.Format("Total Withdrawals {0,13:C2}", totalWithdrawalAmount));
        }

        //Print Deposits summary
        protected void printDeposits()
        {
            double totalDepositAmount = 0.0;
            bool isFirstListed = false;
            Console.WriteLine("\nSummary of Deposits:");
            Console.WriteLine("-------------------------------");
            foreach (Transaction t in Transactions)
            {
                if (t.GetType() == typeof(Deposit))
                {
                    t.print(true,!isFirstListed);
                    isFirstListed = true;
                    totalDepositAmount += t.Amount;
                }
            }
            Console.WriteLine("-------------------------------");
            Console.WriteLine(String.Format("Total Deposits {0,16:C2}", totalDepositAmount));
        }

        //Print the whole bank statement
        public void printStatment()
        {
            Console.WriteLine(String.Format("Statement for Account: {0}\n", ID));
            Console.WriteLine(String.Format("Beginning Balance: {0:C2}\n", InitialBalance));

            printWithdrawals();
            printDeposits();

            if (NumbOfOverdafts>0)
            {
                Console.WriteLine("\n*Overdraft Fees");
                Console.WriteLine("--------------");
                for (int i = 0; i < NumbOfOverdafts;i++)
                {
                    Console.WriteLine("{0:C2}", OverdraftCharge);
                    Balance -= OverdraftCharge;
                }
                Console.WriteLine("--------------");
            }
            
            Console.WriteLine("\nEnding Balance:{0,16:C2}",Balance);
            
        }



    }


    class Transaction
    {
        string Source;
        public double Amount {get; set;}

        public Transaction()
        {
            Source = "Default Source";
            Amount = 0.0;
        }

        public Transaction(string source, double amount)
        {
            Source = source;
            Amount = amount;
        }

        public void print(bool newline=false, bool cur=true) {
            Console.Write(String.Format("{0,-15} {1,15:" + (cur ? "'$'#.00#" : "#.00#") + "}", Source, Amount));
            if (newline) Console.WriteLine();
        }

    }


    class Withdrawal : Transaction
    {
        public Withdrawal() : base() { }
        public Withdrawal( string source, double amount) : base(source,amount) { }
    }


    class Deposit : Transaction
    {
        public Deposit() : base() { }
        public Deposit(string source, double amount) : base(source, amount) { }
    }
}
