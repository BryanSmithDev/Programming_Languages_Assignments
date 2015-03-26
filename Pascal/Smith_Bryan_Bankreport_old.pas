//	CSC 4200-01 - Programming Languages
// 	Name: Bryan Smith
//	Date: 3/28/14
//	Description: Bank Report

program Smith_Bryan_Bankreport;
{$H+}
{$mode objfpc}
 
uses
 Classes,
 Sysutils;
    
var
 File1: TextFile;
 Str: AnsiString;
 dollarSign : AnsiString;
 Id : Integer;
 Balance, initialBalance,OverdraftCharge,totalWithdrawal, totalDeposits : Currency;
 SplitString: TStrings;
 count:Integer;
 overDrafted:boolean;

begin
  Balance:=0.0; initialBalance := 0.0; OverdraftCharge:=10.0; count :=0;
  dollarSign:='$'; totalWithdrawal :=0.0; totalDeposits := 0.0; overDrafted:=false;
  AssignFile(File1, 'account.txt');
  {$I+}
  try
    Reset(File1);
    SplitString := TStringList.Create;
    repeat
      Readln(File1, Str); // Reads the whole line from the file
      ExtractStrings([':'], [' '], PChar(Str), SplitString);
    until(EOF(File1));
    CloseFile(File1);
    
    Id:=strtoint(SplitString.Strings[1]);
    initialBalance:=strtocurr(SplitString.Strings[3]);
    Balance:=initialBalance;

    WriteLn('Statement for Account: ',Id); WriteLn(' ');
    WriteLn('Beginning Balance: ',FormatCurr('$0.00 ;( 0.00)',Balance)); WriteLn(' ');
    WriteLn('Summary of Withdrawals:	 amount		Running Balance');
    WriteLn('-------------------------------------------------------');
    count:=4;
    while count <= SplitString.Count do begin
        if (count+2 <= SplitString.Count-1) then
        begin
            if PChar(SplitString.Strings[count]) = 'W' then
            begin
                Balance:=Balance-strtocurr(SplitString.Strings[count+2]);
                if (Balance < 0) then overDrafted:=true;
                totalWithdrawal:=totalWithdrawal+strtocurr(SplitString.Strings[count+2]);
                WriteLn(Format('%-21s %9s %25s',[SplitString.Strings[count+1],Format('%s%s',[dollarSign,FormatCurr('0.00',strtocurr(SplitString.Strings[count+2]))]),FormatCurr('0.00  ;( 0.00)*',Balance)]));
                dollarSign:=' ';
            end
            else
            begin
                Balance:=Balance+strtocurr(SplitString.Strings[count+2]);
                WriteLn('--deposit(see below)');
            end;

        end;
        Inc(count, 3);
    end;
    WriteLn('-------------------------------------------------------');
    dollarSign:='$';
    WriteLn(Format('Total Withdrawals %13s',[Format('%s%s',[dollarSign,FormatCurr('0.00',totalWithdrawal)])]));
    WriteLn(' ');
    WriteLn('Summary of Deposits:');
    WriteLn('-------------------------------');
    count:=4;
    while count <= SplitString.Count do begin
        if (count+2 <= SplitString.Count-1) then
        begin
            if PChar(SplitString.Strings[count])='D' then
            begin
                WriteLn(Format('%-21s %9s',[SplitString.Strings[count+1],Format('%s%s',[dollarSign,FormatCurr('0.00',strtocurr(SplitString.Strings[count+2]))])]));
                dollarSign:=' ';
                totalDeposits:=totalDeposits+strtocurr(SplitString.Strings[count+2]);
            end;
        end;
        Inc(count, 3);
    end;
    WriteLn('-------------------------------');
    dollarSign:='$';
    WriteLn(Format('Total Deposits %16s',[Format('%s%s',[dollarSign,FormatCurr('0.00',totalDeposits)])]));
    WriteLn(' ');
    
    if overDrafted = true then
    begin
        WriteLn('*Overdraft Fees');
        WriteLn('--------------');
        WriteLn(FormatCurr('$0.00',overdraftCharge));
        WriteLn('--------------');WriteLn(' ');
        Balance:=Balance-overdraftCharge;
    end;
    
    WriteLn(Format('Ending Balance: %16s',[FormatCurr('$0.00;( $0.00)',Balance)]));

  except
    on E: EInOutError do
    begin
     Writeln('File handling error occurred. Details: '+E.ClassName+'/'+E.Message);
    end;    
  end;
  Readln;
end.
