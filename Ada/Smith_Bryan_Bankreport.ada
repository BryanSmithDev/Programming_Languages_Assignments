--	CSC 4200-01 - Programming Languages
-- 	Name: Bryan Smith
--	Date: 3/29/14
--	Description: Bank Report
with Ada.Strings.Fixed, Ada.Strings.Fixed,Ada.Text_IO,Ada.Integer_Text_IO,Ada.Float_Text_IO;
with Ada.Text_IO.Editing,Ada.Strings.Unbounded;
use Ada.Text_IO, Ada.Integer_Text_IO,Ada.Strings.Unbounded;

procedure Smith_Bryan_Bankreport is
   type Money is delta 0.01 digits 18;
   package Money_IO is new ada.text_io.editing.decimal_output( Money);
   Sign:constant Editing.Picture:=Editing.To_Picture("<$$$$9.99>");
   NonSign:constant Editing.Picture:=Editing.To_Picture("<<<<<<<.<<>");
   My_File  : FILE_TYPE;
   One_Char : Character;
   Line_Count : Integer := 0;
   Balance,initialBalance,OverdraftCharge,totalWithdrawal,totalDeposits : Money;
   overDrafted : Boolean;
   dollarSign : Character;

begin
   Balance:=0.0; initialBalance := 0.0; OverdraftCharge:=10.0;
   dollarSign:='$'; totalWithdrawal :=0.0; totalDeposits := 0.0; overDrafted:=false;
   open(My_File, In_File, "account.txt");
   loop
      exit when End_Of_File(My_File);
      declare
        Line : String := Get_Line(My_File);
      begin
        Line_Count := Line_Count +1;
      end;
   end loop;
   Reset(My_File);
   Line_Count:=(Line_Count*3)-2;
   Put(Integer'Image(Line_Count));
   Declare
    SplitStrings:Array(1..Line_Count) of Unbounded_String;
    counter : Integer := 1;
    dollarSign : String := "$";
    subtype Source_String is String (1..21); 
    subtype Amount_String is String (1..10);
    subtype Balance_String is String (1..24); 
    tmpString1 : Source_String;
    tmpString2 : Amount_String;
    tmpString3 : Balance_String;
   Begin
      loop
      exit when End_Of_File(My_File);
        Get(My_File,One_Char);
        if End_Of_Line(My_File) OR One_Char = ':' then
            counter:=counter+1;
            New_Line;
        else
            if counter <= Line_Count then 
                SplitStrings(counter):=SplitStrings(counter)&One_Char;
            end if;
        end if;

      end loop;
      Close (My_File);
      
      Put("Statement for Account: ");
      Put(Ada.Strings.Fixed.Trim(To_String(SplitStrings(2)),
          Ada.Strings.Left)); New_Line; New_Line;
      initialBalance:=Money'Value(Ada.Strings.Fixed.Trim (To_String(SplitStrings(4)),Ada.Strings.Left));
      Balance:=initialBalance;
      Put("Beginning Balance:");
      Money_IO.Put(initialBalance,Sign); New_Line; New_Line;
      
      Put("Summary of Withdrawals:  amount         Running Balance");New_Line;
      Put("-------------------------------------------------------");New_Line;
      counter:=5;
      loop 
      exit when counter > SplitStrings'Length;
        if To_String(SplitStrings(counter)) = "W" then
            Balance:=Balance-Money'Value(To_String(SplitStrings(counter+2)));
            
            totalWithdrawal:=totalWithdrawal+Money'Value(To_String(SplitStrings(counter+2)));
            Ada.Strings.Fixed.Move(To_String(SplitStrings(counter+1)),tmpString1,Ada.Strings.Left);
            Ada.Strings.Fixed.Move(dollarSign&To_String(SplitStrings(counter+2)),tmpString2,Justify=>Ada.Strings.Right);
            dollarSign := " ";
            
            if Balance < 0.0 then
                Ada.Strings.Fixed.Move("("&Money'Image(-Balance),tmpString3,Justify=>Ada.Strings.Right); 
                overDrafted:=true;
                Put(tmpString1);Put(tmpString2);Put(tmpString3);put(")*");
            else
                Ada.Strings.Fixed.Move(Money'Image(Balance),tmpString3,Justify=>Ada.Strings.Right);
                Put(tmpString1);Put(tmpString2);Put(tmpString3);
            end if;
            
            new_line;
        else 
            if To_String(SplitStrings(counter)) = "D" then
             Balance:=Balance+Money'Value(To_String(SplitStrings(counter+2)));
             Put("--deposit(see below)");
             new_line;
            end if;
        end if;
        
        counter:=counter+3;
      end loop;
      Put("-------------------------------------------------------");New_Line;
      Ada.Strings.Fixed.Move("Total Withdrawals",tmpString1,Ada.Strings.Left);
      Money_IO.Put(tmpString2,totalWithdrawal,Sign);
      Ada.Strings.Fixed.Move(tmpString2,tmpString2,Justify=>Ada.Strings.Right);
      Put(tmpString1&" ");Put(tmpString2);
      new_line;new_line; dollarSign:="$";
      Put("Summary of Deposits:");New_Line;
      Put("-------------------------------");New_Line;
      counter:=5;
      loop 
      exit when counter > SplitStrings'Length;
        if To_String(SplitStrings(counter)) = "D" then
            totalDeposits:=totalDeposits+Money'Value(To_String(SplitStrings(counter+2)));
            Ada.Strings.Fixed.Move(To_String(SplitStrings(counter+1)),tmpString1,Ada.Strings.Left);
            Ada.Strings.Fixed.Move(dollarSign&To_String(SplitStrings(counter+2)),tmpString2,Justify=>Ada.Strings.Right);
            dollarSign := " ";
            Put(tmpString1);Put(tmpString2);
            new_line;
        end if;
        counter:=counter+3;
      end loop;
      Put("-------------------------------");New_Line;
      Ada.Strings.Fixed.Move("Total Deposits",tmpString1,Ada.Strings.Left);
      Money_IO.Put(tmpString2,totalDeposits,Sign);
      Ada.Strings.Fixed.Move(tmpString2,tmpString2,Justify=>Ada.Strings.Right);
      Put(tmpString1&" ");Put(tmpString2);
      new_line;new_line;
      
      if overDrafted = true then
        Put_Line("*Overdraft Fees");
        Put_Line("--------------");
        Money_IO.Put(tmpString2,OverdraftCharge,Sign);
        Ada.Strings.Fixed.Move(Ada.Strings.Fixed.Trim(tmpString2,Ada.Strings.Left),tmpString2,Justify=>Ada.Strings.Left);
        Put_Line(tmpString2);
        Put_Line("--------------");
        Balance:=Balance-OverdraftCharge;
        new_line;
      end if;
      Ada.Strings.Fixed.Move("Ending Balance:",tmpString1,Ada.Strings.Left);
      Money_IO.Put(tmpString2,Balance,Sign);
      Ada.Strings.Fixed.Move(tmpString2,tmpString2,Justify=>Ada.Strings.Right);
      Put(tmpString1&" ");Put_line(tmpString2);
      Ada.Text_IO.Get_Line(tmpString2, counter);
   end;
end Smith_Bryan_Bankreport;
