unit BetterArray;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Rtti,
  System.SysUtils,
  DUnitX.Generics;

type
  TBetterArray<T> = record
  private
    FValues: IList<T>;
  public
    class operator Implicit(AType: TArray<T>): TBetterArray<T>;
    class operator Implicit(AType: TBetterArray<T>): string;
    class operator Implicit(AType: TBetterArray<T>): TArray<T>;
    class operator Implicit(AType: TArray<string>): TBetterArray<T>;
    class operator Explicit(AType: TArray<T>): TBetterArray<T>;
    function GetEnumerator: IEnumerator<T>;
    function GetValues: IList<T>;
    procedure Initialize;

    function Add(Value: T): Integer; overload;
    procedure Add(Values: TArray<T>); overload;
    procedure Clear;
    function Contains(Value: T): Boolean;
    function Count: Integer;
    function Exists(Value: T): Boolean;
    function First: T;
    function FirstIndexOf(Value: T): Integer;
    function Get(Index: Integer): T;
    function LastIndexOf(Value: T): Integer;
    function Last: T;
    function Join(Separator, Before, After: string): string; overload;
    function Join(Separator: string = ','): string; overload;
    function JoinQuoted(Separator: string = ','; QuoteString: string = ''''): string;

    constructor Create(Values: TArray<T>); overload;
    constructor Create(dummy: Boolean); overload;
  end;

implementation

uses
  System.Variants;

function TBetterArray<T>.Add(Value: T): Integer;
begin
  Result := GetValues.Add(Value);
end;

procedure TBetterArray<T>.Add(Values: TArray<T>);
begin
  GetValues.AddRange(Values);
end;

procedure TBetterArray<T>.Clear;
begin
  if Assigned(FValues) then
    FValues.Clear;
end;

function TBetterArray<T>.Contains(Value: T): Boolean;
begin
  Result := GetValues.Contains(Value);
end;

function TBetterArray<T>.Count: Integer;
begin
  Result := GetValues.Count;
end;

constructor TBetterArray<T>.Create(dummy: Boolean);
begin
  Initialize;
end;

constructor TBetterArray<T>.Create(Values: TArray<T>);
begin
  GetValues.AddRange(Values);
end;

function TBetterArray<T>.Exists(Value: T): Boolean;
begin
  Result := GetValues.Contains(Value);
end;

class operator TBetterArray<T>.Explicit(AType: TArray<T>): TBetterArray<T>;
begin
  Result.Create(AType);
end;

function TBetterArray<T>.First: T;
begin
  Result := GetValues.First;
end;

function TBetterArray<T>.FirstIndexOf(Value: T): Integer;
begin
  Result := GetValues.FirstIndexOf(Value);
end;

function TBetterArray<T>.Get(Index: Integer): T;
begin
  if (Index < 0) or (Index >= Count) then
    Exit(TValue.Empty.AsType<T>);

  Result := GetValues.Items[Index];
end;

function TBetterArray<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TDUnitXIEnumerator<T>.Create(GetValues);
end;

function TBetterArray<T>.GetValues: IList<T>;
begin
  if not Assigned(FValues) then
    Initialize;

  Result := FValues;
end;

class operator TBetterArray<T>.Implicit(AType: TArray<T>): TBetterArray<T>;
begin
  Result.Create(AType);
end;

class operator TBetterArray<T>.Implicit(AType: TBetterArray<T>): string;
begin
  Result := AType.Join;
end;

class operator TBetterArray<T>.Implicit(AType: TBetterArray<T>): TArray<T>;
begin
  Result := AType.FValues.ToArray;
end;

function TBetterArray<T>.Last: T;
begin
  Result := GetValues.Last;
end;

class operator TBetterArray<T>.Implicit(AType: TArray<string>): TBetterArray<T>;
begin
  Result.Create(TArray<T>(AType));
end;

function TBetterArray<T>.LastIndexOf(Value: T): Integer;
begin
  Result := GetValues.LastIndexOf(Value);
end;

procedure TBetterArray<T>.Initialize;
begin
  FValues := TDUnitXList<T>.Create;
end;

function TBetterArray<T>.Join(Separator: string = ','): string;
begin
  Result := Join(Separator, '', '');
end;

function TBetterArray<T>.Join(Separator, Before, After: string): string;
const
  ItemFmt = '%s%s%s';
var
  Item: T;
  StrValues: TArray<string>;
begin
  for Item in FValues do
    StrValues := StrValues + [Format(ItemFmt, [Before, TValue.From<T>(Item).ToString, After])];

  Result := ''.Join(Separator, StrValues);
end;

function TBetterArray<T>.JoinQuoted(Separator: string = ','; QuoteString: string = ''''): string;
begin
  Result := Join(Separator, QuoteString, QuoteString);
end;

end.
