--------------------------------------------
-- CSC 4200-01 - Programming Languages
-- Name: Bryan Smith
-- Date: 4/4/14
-- Description: Print bank statement based on data read from file
--------------------------------------------

--Loads the specified file storing each line in an arrray.
function loadData(fileName,atype)
	local fileData = {}
	local file = io.open(fileName, atype);
	for line in file:lines() do
		if (line ~= nil) then table.insert (fileData, line); end
	end
	io.close(file);
	return fileData
end

--Trims whitespace from front and back of string.
function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--Splits a string by colons and stores the tokens in an array.
function split(str)
	local splitString = {}
	for word in string.gmatch(str, '([^:]+)') do
		table.insert (splitString, trim(word));
	end
	return splitString;
end

--Returns a currecy formated number
function toCurrency(str,dollarSign)
	if (tonumber(str) < 0) then return string.format("( %.2f)", -str); end
	if (dollarSign) then return string.format("$%.2f", str); end
	return string.format("%.2f", str);
end

--Setup
local fileData = loadData("account.txt", "r");
local sign, overdrafted = true, false;
local acc , iB = split(fileData[1]),split(fileData[2])
local balance = iB[2]
local totalTrans, totalDeposits, overdraftCharge = 0.0 , 0.0 , 10.0

--Print Withdrawals
print(string.format("%s %s\n","Statement for Account:",acc[2]));
print(string.format("%s %s\n","Beginning Balance:",toCurrency(iB[2],true)));
print("Summary of Withdrawals:	 amount		Running Balance");
print("-------------------------------------------------------");
for i=3,#fileData do
	local trans = split(fileData[i])
	if (string.lower(trans[1]) == "w" ) then
		balance = balance - trans[3]; totalTrans = totalTrans+trans[3];
		if (balance < 0) then
			overdrafted = true;
			print(string.format("%-21s %9s %24s*",trans[2],toCurrency(trans[3],sign),toCurrency(balance,false)));
		else
			print(string.format("%-21s %9s %23s",trans[2],toCurrency(trans[3],sign),toCurrency(balance,false)));
		end
	else
		balance = balance + trans[3];
		print("--deposit(see below)");
	end
	sign = false;
end
print("-------------------------------------------------------");
print(string.format("%-21s %9s\n","Total Withdrawals",toCurrency(totalTrans,true)));

--Print Deposits
sign=true
print("Summary of Deposits:");
print("-------------------------------");
for i=3,#fileData do
	local trans = split(fileData[i])
	if (string.lower(trans[1]) == "d" ) then
		totalDeposits = totalDeposits+trans[3];
		print(string.format("%-21s %9s",trans[2],toCurrency(trans[3],sign)));
		sign=false;
	end
end
print("-------------------------------");
print(string.format("%-21s %9s\n","Total Deposits",toCurrency(totalDeposits,true)));

--Print overdraft if applicable
if (overdrafted) then
	print("*Overdraft Fees");
	print("--------------");
	print(toCurrency(overdraftCharge,true));
	print("--------------\n");
	balance=balance-overdraftCharge;
end

print(string.format("%-21s %9s\n","Ending Balance:",toCurrency(balance,true))); --Print balance
