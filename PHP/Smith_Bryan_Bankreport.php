<?php
///////////////////////////////////////////////////////////////////////////////
// CSC 4200-01 - Programming Languages
// Name: Bryan Smith
// Date: 3/5/14
// Description: Print bank statement based on data read from
//              file
// Parameters:
//   fileLoc - Path to the file to read.
///////////////////////////////////////////////////////////////////////////////

//Disable warnings. Might want to remove for debugging.
error_reporting(E_ERROR | E_PARSE); 

//Get arguments from either command line or URL
$fileLoc=null;
if ($argv[1] != "" && $argv[1] != null) {
	$fileLoc=$argv[1];
} else {
	$fileLoc = htmlspecialchars($_GET["fileName"]);
	if ($fileLoc == "" || $fileLoc == null) $fileLoc="TestData.txt";
}

//Create an account object, load in the file and parse it. 
//Then output the statement.
$account = new Account(0,0.0,10.0);
$account->parseToAccount(readDataFile($fileLoc));
echo $account;

///////////////////////////////////////////////////////////////////////////////

//Reads in a file returning the array of lines of what was read.
function readDataFile($fileLoc){
    try {
        $contents = array();
        $file = fopen( $fileLoc, "r" );
        if( $file == false )
        {
			echo "\nError in opening file ".$fileLoc."  Does it exist?\n\n";
			if (php_sapi_name() != 'cli') echo "You can also pass in the file name by adding ?fileName=FILENAME.txt  after the .php in the URL";
			else echo "You can also pass in the file name by adding it as a command line argument";
			exit();
        } else {
            while (($line = fgets($file)) !== false) {
                array_push($contents,$line);
            }   
        }
        fclose( $file );
        return $contents;
    } catch (Exception $e) {
        echo "\nError in opening file ".$fileLoc."  Does it exist?\n\n".$e->getMessage();
    }
}

//****************
//  Account Class
//****************
class Account {
	private $id = 0;
    private $balance = 0.0;
    private $initialBalance = 0.0;
    private $transactions = array();
    private $numbOfOverdrafts = 0;
    private $overdraftedLast = false;
    private $overdraftCharge = 10.0;
    
    public function Account($i,$b,$o=10.0) {
        $this->id = $i;
        $this->balance = $b;
        $this->initialBalance = $b;
        $this->overdraftCharge = $o;
    }
    
	//Parses data from an array into data to load into the account
    public function parseToAccount($s){
        try {
            $idString = explode(":",$s[0]);
            if ($this->startsWith($idString[0],"a",false)){
                $this->id = trim($idString[1]);
            } else {throw new Exception("Could not parse account number.");}
            $iBString = explode(":",$s[1]);
            if ($this->startsWith($iBString[0],"b",false)){
                $this->initialBalance = trim($iBString[1]);
                $this->balance = $this->initialBalance;
            } else {throw new Exception("Could not parse initial balance.");}

            for ($i=2;$i<count($s);$i++){
                $splitString = explode(":",$s[$i]);
                if ($this->startsWith($splitString[0],"d",false)) 
                    $this->addTransaction(new Deposit(trim($splitString[1]),trim($splitString[2])));
                else if ($this->startsWith($splitString[0],"w",false))
                    $this->addTransaction(new Withdrawal(trim($splitString[1]),trim($splitString[2])));
                else
                  throw new Exception("Failed to parse transactions.\n");  
            }
            $this->calculateBalance();
        } catch (Exception $e) {
            echo "\nError in parsing data.\n\n".$e->getMessage();
        } 
    }
    
	//Adds a transaction to the account
    private function addTransaction($t){
        try {
            array_push($this->transactions,$t);
        } catch (Exception $e) {
            echo "\nError adding transaction.\n\n".$e->getMessage();
        } 
    }
    
	 //Calculates the final balance and any overdrafts
    public function calculateBalance(){
        $this->balance = $this->initialBalance;
        foreach ($this->transactions as $t)
        {
            if ($t instanceof Deposit) {
                $this->balance += $t->getAmount();
            } else {
                $this->balance -= $t->getAmount();
            }
            
            if ($this->balance < 0 && !$this->overdraftedLast){
                $this->numbOfOverdrafts++;
                $this->overdraftedLast=true;
                $this->balance -= $this->overdraftCharge;
            } else if ($this->balance >= 0 && $this->overdraftedLast) {
                $this->overdraftedLast=false; 
            }
        }
    }
    
	//Determine if a sting starts with a specified character
    private function startsWith($haystack,$needle,$case=true){
        if($case)
            return strpos(trim($haystack), $needle, 0) === 0;
        return stripos(trim($haystack), $needle, 0) === 0;
    }
    
	//Print withdrawal summary
    private function printWithdrawals(){
        $totalWithdrawalAmount = 0.0;
        $tmpBalance = $this->initialBalance;
        $isFirstListed=false;
        
        echo "Summary of Withdrawals:	 amount	        Running Balance\n";
        echo "-------------------------------------------------------\n";
        foreach ($this->transactions as $t) {
            if ($t instanceof Deposit) { 
                echo "--deposit(see below)";
                $tmpBalance+=$t->getAmount();
            } else {
                $t->printTrans(false,!$isFirstListed); 
                $isFirstListed = true;
                $totalWithdrawalAmount += $t->getAmount();
                if ($tmpBalance <0 ) $this->overdraftedLast=true; 
                else $this->overdraftedLast=false;
                $tmpBalance -= $t->getAmount();
                if ($tmpBalance < 0 && $this->overdraftedLast == false) {
                    echo sprintf("%26s",sprintf("( %.2f)*",-$tmpBalance));   
                } else {
                    echo sprintf("%24s",sprintf("%.2f",$tmpBalance));  
                }
            }
            echo "\n";
        }
        echo "-------------------------------------------------------\n";
        echo sprintf("Total Withdrawals %13s\n",sprintf("$%.2f",$totalWithdrawalAmount));
    }
    
	//Print deposit summary
    private function printDeposits(){
        $totalDepositAmount = 0.0;
        $isFirstListed=false;

        echo "\nSummary of Deposits:\n";
        echo "-------------------------------\n";
        foreach ($this->transactions as $t) {
            if ($t instanceof Deposit) { 
                $t->printTrans(true,!$isFirstListed); 
                $isFirstListed = true;
                $totalDepositAmount += $t->getAmount();
            }
        }
        echo "-------------------------------\n";
        echo sprintf("Total Deposits %16s\n",sprintf("$%.2f",$totalDepositAmount));
    }
    
	//Print whole account statement
    public function __toString() {
		if (php_sapi_name() != 'cli') 
			echo "<html><body><pre style='word-wrap: break-word; white-space: pre-wrap;'>";
        echo "Statement for Account: ".$this->id."\n\n";
        echo "Beginning Balance: $".$this->initialBalance."\n\n";
        $this->printWithdrawals();
        $this->printDeposits();
        
        if ($this->numbOfOverdrafts>0){
            echo "\n*Overdraft Fees\n";
            echo "--------------\n";
            for ($i = 0; $i < $this->numbOfOverdrafts;$i++){
                echo sprintf("$%.2f\n",$this->overdraftCharge);
            }
            echo "--------------\n";
        }
        if ($this->balance <0)
            echo sprintf("\nEnding Balance: %15s\n",sprintf("( %.2f)",-$this->balance));
        else
            echo sprintf("\nEnding Balance: %15s\n",sprintf("$%.2f",$this->balance));
		
		if (php_sapi_name() != 'cli') echo "</pre></body></html>";
        return "";
    }
    
}

//****************
//  Transaction Class
//****************
class Transaction {
	private $source = "Default Source";
	private $amount = 0.0;
    
    public function Transaction($s,$a) {
        $this->source = $s;
        $this->amount = $a;
    }
	
	public function setSource($s){
		$this->source = $s;
	}
	
	public function getSource(){
		return $this->source;
	}
	
	public function setAmount($a){
		$this->amount = $a;
	}
	
	public function getAmount(){
		return $this->amount;
	}
	
	//Print the transaction
	public function printTrans($newLine, $cur) {
		if ($cur)
            echo sprintf("%-21s %9s",$this->getSource(),sprintf("$%.2f",$this->getAmount()));
        else
            echo sprintf("%-21s %9.2f",$this->getSource(),$this->getAmount());
        
        if ($newLine) echo "\n";

	}
}

//****************************
//  Withdrawal and Deposit Classes
//****************************
class Withdrawal extends Transaction{}
class Deposit extends Transaction {}
?> 