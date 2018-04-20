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
    function GetItem(Index: Integer): T;
    function TypeIsClass: Boolean;
  public
    class operator Implicit(AType: TArray<T>): TBetterArray<T>;
    class operator Implicit(AType: TBetterArray<T>): string;
    class operator Implicit(AType: TBetterArray<T>): TArray<T>;
    class operator Implicit(AType: TArray<string>): TBetterArray<T>;
    class operator Explicit(AType: TArray<T>): TBetterArray<T>;
    function GetEnumerator: IEnumerator<T>;
    function GetValues: IList<T>;
    procedure Initialize;
    constructor Create(Values: TArray<T>); overload;

    function Add(Value: T): Integer; overload;
    procedure Add(Values: TArray<T>); overload;
    procedure Clear;
    function Contains(Value: T): Boolean;
    function Count: Integer;
    function Compact: TBetterArray<T>;
    function Exists(Value: T): Boolean;
    function First: T;
    function FirstIndexOf(Value: T): Integer;
    procedure FreeAll;
    function Get(Index: Integer): T;
    property Items[Index: Integer]: T read GetItem; default;
    function LastIndexOf(Value: T): Integer;
    function Last: T;
    function Join(Separator, Before, After: string): string; overload;
    function Join(Separator: string = ','): string; overload;
    function JoinQuoted(Separator: string = ','; QuoteString: string = ''''): string;
    function Reverse: TBetterArray<T>;
    function Sort: TBetterArray<T>; overload;
    function Sort(const Comparison: TComparison<T>): TBetterArray<T>; overload;
    function ToStrings(Func: TFunc<T, string>): TBetterArray<string>;
  end;

implementation

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

function TBetterArray<T>.Compact: TBetterArray<T>;
var
  Item: T;
  Comparer: IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;
  for Item in Self do
    if not Comparer.Equals(Item, TValue.Empty.AsType<T>) then
      Result.Add(Item);
end;

function TBetterArray<T>.Contains(Value: T): Boolean;
begin
  Result := GetValues.Contains(Value);
end;

function TBetterArray<T>.Count: Integer;
begin
  Result := GetValues.Count;
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

procedure TBetterArray<T>.FreeAll;
var
  Item: T;
begin
  if not TypeIsClass then
    Exit;

  for Item in Self do
    TValue.From<T>(Item).AsObject.Free;
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

function TBetterArray<T>.GetItem(Index: Integer): T;
begin
  Result := GetValues.Items[Index];
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

function TBetterArray<T>.Reverse: TBetterArray<T>;
begin
  GetValues.Reverse;
  Result := Self;
end;

function TBetterArray<T>.Sort(const Comparison: TComparison<T>): TBetterArray<T>;
begin
  GetValues.Sort(TDelegatedComparer<T>.Construct(Comparison));
  Result := Self;
end;

function TBetterArray<T>.ToStrings(Func: TFunc<T, string>): TBetterArray<string>;
var
  Item: T;
begin
  for Item in Self do
    Result.Add(Func(Item));
end;

function TBetterArray<T>.Sort: TBetterArray<T>;
begin
  GetValues.Sort;
  Result := Self;
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

function TBetterArray<T>.TypeIsClass: Boolean;
begin
  Result := TRttiContext.Create.GetType(TypeInfo(T)).TypeKind = tkClass
end;

end.
