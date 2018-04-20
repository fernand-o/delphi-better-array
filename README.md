## Overview
`TBetterArray<T>` is just a workaround to provide instance methods for arrays.

## Why?
The generic class `TArray<T>` was introduced in Deplhi XE2 to give a better approach of manipulating dynamic arrays. 
Although it was a huge step for delphi, `TArray<T>` is far behind array implementations of any modern programming languages.

## Usage
The usage is the same of `TArray<T>`, however there are some examples described bellow.

For the complete list of available methods, please check the [source](https://github.com/fernand-o/delphi-better-array/blob/master/BetterArray.pas#L29) and the examples at the [test unit](https://github.com/fernand-o/delphi-better-array/blob/master/tests/BetterArrayTests.pas).

### Simple types
```[delphi]
var
  People: TBetterArray<string>;
begin
  People := ['Fernando', 'John', 'Paul'];
  
  People.Count;             // 3
  People.Join('-');         // 'Fernando-John-Paul'
  People.First;             // 'Fernando'  
  People.Contains('Trump'); // False
  People.Reverse;           // ['Paul', 'John', 'Fernando']  
  People.Add('Bill');       // ['Paul', 'John', 'Fernando', 'Bill']
end;
  
```

### Complex types
```[delphi]
TCoffee = class
  Name: string;  
  Origin: string;
  Strength: Integer;  
  constructor Create(Name, Origin: string; Strength: Integer);
end;

...

var 
  Coffees: TBetterArray<TCoffee>;
begin
  Coffees := [
    TCoffee.Create('Arabic', 'Egypt', 5),  
    TCoffee.Create('Turkish', 'Turkey', 8),
    TCoffee.Create('Capuccino', 'Italy', 2)
  ];  
end;  
```

#### Sorting
```[delphi]
var
  StrengthComparison: TComparison<TCoffee>;
begin
  StrengthComparison := 
    function(const Left, Right: TCoffee): Integer
    begin
      Result := Left.Strength - Right.Strength;
    end;  
    
  Coffees.Sort(StrengthComparison);
  Coffees.First.Name; // 'Capuccino'
  Coffees.Last.Name;  // 'Turkish'  
```

#### Retrieving values
```[delphi]
  Coffees[1];      // TCoffee instance
  Coffees[5];      // Error
  Coffees.Get(1);  // TCoffee instance
  Coffees.Get(5);  // nil
```
