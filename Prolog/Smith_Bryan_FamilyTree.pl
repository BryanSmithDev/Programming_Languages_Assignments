% CSC 4200-01 - Programming Languages
% Name: Bryan Smith
% Date: 5/2/14
% Description: Prolog Family Tree

%Given the following facts, write the required relationships:

parent(fred, jacob).
parent(fred, james).
parent(fred, jason).
parent(fred, john).
parent(fred, lillian).
parent(fred, logan).
parent(jean, james).
parent(jean, jason).
parent(jean, lillian).
parent(jean, john).
parent(jean, jacob).
parent(jean, logan).
parent(paul,fred).
parent(lucille, fred).
parent(edgar, jean).
parent(beulah, jean).
parent(logan, xander).
parent(logan, drake).
parent(logan, lexa).
parent(logan, tess).
parent(logan, zoe).
parent(james, adam).
parent(james, emily).
parent(james, stephanie).
parent(jason, ashley).
parent(jason, eric).
parent(john, adera).
parent(john, evan).
parent(lillian, kelly).
parent(lillian, kayla).
parent(lillian, andrew).
parent(pam, xander).
parent(pam, drake).
parent(pam, lexa).
parent(pam, tess).
parent(pam, zoe).
parent(dee, adera).
parent(dee, evan).
parent(amy, ashley).
parent(amy, eric).
parent(alice, adam).
parent(alice, emily).
parent(alice, stephanie).
parent(jack, kelly).
parent(jack, kayla).
parent(jack, andrew).
parent(jacob, steven).
parent(cyndy, steven).
parent(jacob, katherine).
parent(cyndy, katherine).
born(fred, 1942).
born(jean, 1945).
born(lillian, 1965).
born(jack,1960).
born(james, 1967).
born(alice, 1973).
born(jason, 1969).
born(amy, 1968).
born(john, 1973).
born(dee, 1973).
born(jacob, 1977).
born(cyndy, 1976).
born(logan, 1979).
born(pam, 1978).

male(fred).
male(jacob).
male(logan).
male(john).
male(jason).
male(james).
male(paul).
male(edgar).
male(xander).
male(drake).
male(adam).
male(evan).
male(andrew).
male(eric).
male(jack).
male(steven).

female(pam).
female(alice).
female(jean).
female(lillian).
female(lucille).
female(beulah).
female(lexa).
female(dee).
female(amy).
female(ashley).
female(kelly).
female(kayla).
female(emily).
female(stephanie).
female(adera).
female(tess).
female(zoe).
female(katherine).
female(cyndy).

% Father and Mother
father(X,Y):-parent(X,Y),male(X).  
mother(X,Y):-parent(X,Y),female(X).

% Siblings
sibling(X, Y) :- father(Z, X),  father(Z, Y), mother(J, X),  mother(J, Y), \+ (X = Y).
brother(X,Y):-sibling(X,Y),male(X).  
sister(X,Y):-sibling(X,Y),female(X). 

% Married or not
married(X, Y) :- male(X), female(Y),not(notMarried(X,Y)), \+ (X=Y).
notMarried(X, Y) :- male(X), female(Y), not((parent(X, Z), parent(Y, Z))).

% Aunts and Uncles
auntOrUncle(X, Z) :- sibling(X, Y), parent(Y, Z).
auntOrUncle(X, Z) :- married(X,Y),  sibling(Y,J), parent(J,Z).
uncle(X, Y) :- auntOrUncle(X, Y), male(X).
aunt(X, Y) :- auntOrUncle(X, Y), female(X).

% Nieces or Nephews
nieceOrNephew(X, Y) :- parent(Z, X),  sibling(Z, Y).
nephew(X, Y) :- nieceOrNephew(X, Y), male(X).
niece(X, Y) :- nieceOrNephew(X, Y), female(X).

% Grandparents and grand children
grandparent(X, Z) :- parent(X, Y),  parent(Y, Z).
grandchild(X, Z) :- grandparent(Z, X).

% Great-Grandparents and great-grand children
greatgrandparent(X, Z) :- parent(X, Y),  grandparent(Y, Z).
greatgrandchild(X, Z) :- child(X, Y),   grandchild(Y, Z).

% Age
age(X,Y) :- born(X,Z), Y is 2014 - Z.

% Define relationships for determining great-grandparents, 
% grandparents, grandchildren, great-grandchildren, mothers, fathers, brothers, 
% sisters, aunts (female sibling of either parent, or female spouse of sibling of 
% either parent), uncles (male siblings of either parent, or male spouse of 
% sibling of either parent), nieces, nephews, age (in years), and whether or not two people are 
% married. We are assuming that there are no divorces in this world so that if 
% two people are parents of the same child, they must be married.
