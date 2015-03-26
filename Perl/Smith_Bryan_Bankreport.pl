#!/usr/bin/perl
##########################################################
# CSC 4200-01 - Programming Languages
# Name: Bryan Smith
# Date: 2/28/14
# Description: Print bank statement based on data read from
#              file
# Parameters:
#   fileLoc - Path to the file to read.
##########################################################

use constant { true => 1, false => 0 };

#Check for command line file location. If not specified use default.
if (scalar @ARGV >= 1) {
 $fileLoc = @ARGV[0]; 
} else {
 $fileLoc = "TestData.txt"; 
}

#Open file based on supplied file location and store the variable.
open(DATA, "<".$fileLoc) or die "Error reading file ".$fileLoc." Does it exist?";
@fileContents = <DATA>;
close DATA or warn "Error closing input file.";

#Main setup
#Parses the file, loading the content into an Account object. Then prints out the statement that object generates.
eval {
  @line1 = split(/:/,@fileContents[0]);
  @line2 = split(/:/,@fileContents[1]);
  $curAccount = new Account(trim(@line1[1]),trim(@line2[1]),10.0);
  
  for($i=2;$i<scalar @fileContents;$i=$i+1) {
    @split = split(/:/,@fileContents[$i]);
    @split[0] = substr(@split[0], 0, 1);
    @split[0] =~ tr/[A-Z]/[a-z]/;
    if (@split[0] eq 'd') {
        $curAccount->addTransaction(new Deposit(trim(@split[1]),trim(@split[2])));
    }elsif (@split[0] eq 'w') {
        $curAccount->addTransaction(new Withdrawal(trim(@split[1]),trim(@split[2])));
    }
  }
  $curAccount->calculateBalance();
  $curAccount->print();
  1;
} or do {
    my $e = $@;
    print("Error: $e\n");
};

#Trim leading and trailing space
sub trim {
    (my $s = $_[0]) =~ s/^\s+|\s+$//g;
    return $s;        
}

########################
# Account Class
########################
package Account;
sub new
{

    my $self = {
        _class => shift,
        _id => shift,
        _initialBalance => shift,
        _balance => _initialBalance,
        _numberOfOverdrafts => 0,
        _overdraftedLast => false,
        _overdraftCharge => shift,
        _transactions => [],
    };

    bless $self;
    return $self;
}

#Adds a transaction to the account
sub addTransaction {
  my ( $self, $t ) = @_;
  $trans = $t if defined($t);
  push (@{$self->{'_transactions'}}, $trans);    
}

#Calculates the final balance and any overdrafts
sub calculateBalance {
    my ( $self, $t ) = @_;
    $self->{_balance}=$self->{_initialBalance};
    foreach $t (@{$self->{'_transactions'}}) { 
          if ($t->{'_class'} eq "Deposit") {
              $self->{_balance}+=$t->getAmount();
          } else {
              $self->{_balance}-=$t->getAmount();
          }
          if ($self->{_balance} < 0 and $self->{_overdraftedLast} eq false) {
              $self->{_numberOfOverdrafts}++;
              $self->{_overdraftedLast}=true;
          } elsif ($self->{_balance} >= 0 and $self->{_overdraftedLast} eq true) {
             $self->{_overdraftedLast}=false;
          }
    }
}

#Prints the entire account statement
sub print {
     my( $self ) = @_;
     
     printf("Statement for Account: %s\n",$self->{'_id'});
     printf("\nBeginning Balance: \$%.2f \n\n",$self->{'_initialBalance'});
     $self->printWithdrawals();
     $self->printDeposits();
     
     if ($self->{_numberOfOverdrafts}>0) {
            print("\n*Overdraft Fees\n");
            print("--------------\n");
            for ($i=0;$i<$self->{'_numberOfOverdrafts'};$i++){
                printf("\$%.2d\n",$self->{'_overdraftCharge'});
                $self->{_balance}=($self->{_balance}-$self->{_overdraftCharge});
            }
            print("--------------\n");
      }
      if ($self->{_balance} >= 0) {
        printf("%-21s %12s","\nEnding Balance:",sprintf("\$%.2f\n\n",$self->{_balance}));
      } else {
         printf("%-21s %12s","\nEnding Balance:",sprintf("( \$%.2f)\n\n",-$self->{_balance})); 
      }
     

}

#Prints the withdrawals summary
sub printWithdrawals {
     my( $self) = @_;
     $totalWithdrawalAmount=0.0;
     $tmpBalance=$self->{_initialBalance};
     $isFirstListed=true;
     
     print("Summary of Withdrawals:  amount         Running Balance\n");
     print("-------------------------------------------------------\n");
     
     foreach $t (@{$self->{'_transactions'}}) {
         if ($t->{'_class'} eq "Deposit") {
            print("--deposit(see below)");
            $tmpBalance+=$t->getAmount();
         } else {
             $t->print($isFirstListed,false);
             $isFirstListed=false;
             $totalWithdrawalAmount+=$t->getAmount();
             if($tmpBalance <0) {
                    $self->{_overdraftedLast}=true;
             } else {
                    $self->{_overdraftedLast}=false;
             }
             $tmpBalance-=$t->getAmount();
              if($tmpBalance > 0) {
                  printf("%24s",sprintf("%.2f",$tmpBalance));
              } elsif ($tmpBalance <0 and $self->{_overdraftedLast} eq false){
                  printf("%25s",sprintf("( %.2f)",-$tmpBalance));
                  print("*");
              }
         }
         print("\n");
     }
     print("-------------------------------------------------------\n");
     printf("%-21s %9s","Total Withdrawals",sprintf("\$%.2f",$totalWithdrawalAmount));
     print("\n");
}

#Prints the deposits summary
sub printDeposits {
     my( $self) = @_;
     $totalDepositAmount=0.0;
     $isFirstListed=true;
     
     print("\nSummary of Deposits:\n");
     print("-------------------------------\n");
     
     foreach $t (@{$self->{'_transactions'}}) {
         if ($t->{'_class'} eq "Deposit") {
            $t->print($isFirstListed,false);
            $isFirstListed=false;
            $totalDepositAmount+=$t->getAmount();
            print("\n");
         }
         
     }
     print("-------------------------------\n");
     printf("%-21s %9s","Total Deposits",sprintf("\$%.2f",$totalDepositAmount));
     print("\n");
}
1;


########################
# Transaction Class
########################
package Transaction;
sub new
{

    my $self = {
        _class => shift,
        _source => shift,
        _amount => shift,
    };
    bless $self;
    return $self;
}

sub setSource {
    my ( $self, $source ) = @_;
    $self->{_source} = $source if defined($source);
    return $self->{_source};
}

sub getSource {
    my( $self ) = @_;
    return $self->{_source};
}

sub setAmount {
    my ( $self, $amount ) = @_;
    $self->{_amount} = $amount if defined($amount);
    return $self->{_amount};
}

sub getAmount {
    my( $self ) = @_;
    return $self->{_amount};
}

sub print {
    my( $self,$cur,$newline ) = @_;
    $source = $self->getSource();
    $amount = $self->getAmount();
    if ($cur eq true) {
        printf("%-21s %9s",$source,sprintf("\$%.2f",$amount));
    } else {
        printf("%-21s %9s",$source,sprintf("%.2f",$amount));
    }
    if ($newline eq true) {print "\n";}
}

1;


########################
# Withdrawal Class
########################
package Withdrawal;
use base 'Transaction';
use strict;
our @ISA = qw(Transaction);
1;   


########################
# Deposit Class
########################
package Deposit;
use base 'Transaction';
use strict;
our @ISA = qw(Transaction);
1;   
