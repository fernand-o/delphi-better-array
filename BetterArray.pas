unit BetterArray;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Rtti,
  System.SysUtils;

type
  TBetterArray<T> = record
  type
    TEnumerator = class
    private
      FValue: ^TBetterArray<T>;
      FIndex: integer;
      function GetCurrent: T;
    public
      constructor Create(var AValue: TBetterArray<T>);
      function MoveNext: Boolean;
      property Current: T read GetCurrent;
    end;
  private
    FItems: TArray<T>;
    function GetItem(Index: Integer): T;
    function TypeIsClass: Boolean;
  public
    class operator Implicit(AType: TArray<T>): TBetterArray<T>;
    class operator Implicit(AType: TBetterArray<T>): string;
    class operator Implicit(AType: TBetterArray<T>): TArray<T>;
    class operator Implicit(AType: TArray<string>): TBetterArray<T>;
    class operator Explicit(AType: TArray<T>): TBetterArray<T>;
    function GetEnumerator: TEnumerator;
    constructor Create(Values: TArray<T>); overload;

    function Add(Value: T): Integer; overload;
    procedure Add(Values: TArray<T>); overload;
    procedure Clear;
    function Contains(Value: T): Boolean;
    function Count: Integer;
    function Compact: TBetterArray<T>; overload;
    function Compact(Items: TBetterArray<T>): TBetterArray<T>; overload;
    function Copy: TBetterArray<T>;
    function First: T;
    function FirstIndexOf(Value: T): Integer;
    procedure FreeAll;
    function Get(Index: Integer): T;
    function IndexOf(Value: T; const Comparer: IComparer<T>): Integer; overload;
    function IndexOf(Value: T): Integer; overload;
    property Items[Index: Integer]: T read GetItem; default;
    function Last: T;
    function LastIndexOf(Value: T): Integer; overload;
    function LastIndexOf(Value: T; const Comparer: IComparer<T>): Integer; overload;
    function Map(Func: TFunc<T, T>): TBetterArray<T>;
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
  FItems := FItems + [Value];
  Result := Pred(Count);
end;

procedure TBetterArray<T>.Add(Values: TArray<T>);
begin
  FItems := FItems + Values;
end;

procedure TBetterArray<T>.Clear;
begin
  FItems := [];
end;

function TBetterArray<T>.Compact: TBetterArray<T>;
begin
  Result := Map(function(Item: T): T
    begin
      Result := Item;
    end);
end;

function TBetterArray<T>.Compact(Items: TBetterArray<T>): TBetterArray<T>;
var
  Item: T;
  Comparer: IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;
  for Item in Items do
    if not Comparer.Equals(Item, TValue.Empty.AsType<T>) then
      Result.Add(Item);
end;

function TBetterArray<T>.Contains(Value: T): Boolean;
begin
  Result := IndexOf(Value) <> -1;
end;

function TBetterArray<T>.Copy: TBetterArray<T>;
var
  Item: T;
begin
  for Item in FItems do
    Result.Add(Item);
end;

function TBetterArray<T>.Count: Integer;
begin
  Result := Length(FItems);
end;

constructor TBetterArray<T>.Create(Values: TArray<T>);
begin
  Add(Values);
end;

class operator TBetterArray<T>.Explicit(AType: TArray<T>): TBetterArray<T>;
begin
  Result.Create(AType);
end;

function TBetterArray<T>.First: T;
begin
  Result := Get(0);
end;

function TBetterArray<T>.FirstIndexOf(Value: T): Integer;
begin
  Result := IndexOf(Value);
end;

procedure TBetterArray<T>.FreeAll;
var
  Item: T;
begin
  if not TypeIsClass then
    Exit;

  for Item in FItems do
    TValue.From<T>(Item).AsObject.Free;
end;

function TBetterArray<T>.Get(Index: Integer): T;
begin
  if (Index < 0) or (Index >= Count) then
    Exit(TValue.Empty.AsType<T>);

  Result := FItems[Index];
end;

function TBetterArray<T>.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

function TBetterArray<T>.GetItem(Index: Integer): T;
begin
  Result := FItems[Index];
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
  Result := AType.FItems;
end;

function TBetterArray<T>.Last: T;
begin
  Result := Get(Pred(Count));
end;

function TBetterArray<T>.LastIndexOf(Value: T; const Comparer: IComparer<T>): Integer;
begin
  for Result := High(FItems) downto Low(FItems) do
    if Comparer.Compare(FItems[Result], Value) = 0 then
      Exit;
  Result := -1;
end;

function TBetterArray<T>.LastIndexOf(Value: T): Integer;
begin
  Result := LastIndexOf(Value, TComparer<T>.Default);
end;

function TBetterArray<T>.Map(Func: TFunc<T, T>): TBetterArray<T>;
var
  Item: T;
  Comparer: IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;
  for Item in FItems do
    if not Comparer.Equals(Item, TValue.Empty.AsType<T>) then
      Result.Add(Func(Item));
end;

class operator TBetterArray<T>.Implicit(AType: TArray<string>): TBetterArray<T>;
begin
  Result.Create(TArray<T>(AType));
end;

function TBetterArray<T>.Reverse: TBetterArray<T>;
var
  I: Integer;
begin
  Result.Clear;
  for I := High(FItems) downto Low(FItems) do
    Result.Add(FItems[I]);
end;

function TBetterArray<T>.Sort: TBetterArray<T>;
begin
  Result := Copy;
  TArray.Sort<T>(Result.FItems);
end;

function TBetterArray<T>.Sort(const Comparison: TComparison<T>): TBetterArray<T>;
begin
  Result := Copy;
  TArray.Sort<T>(Result.FItems, TDelegatedComparer<T>.Construct(Comparison));
end;

function TBetterArray<T>.ToStrings(Func: TFunc<T, string>): TBetterArray<string>;
var
  Item: T;
begin
  for Item in FItems do
    Result.Add(Func(Item));
end;

function TBetterArray<T>.IndexOf(Value: T): Integer;
begin
  Result := IndexOf(Value, TComparer<T>.Default);
end;

function TBetterArray<T>.IndexOf(Value: T; const Comparer: IComparer<T>): Integer;
begin
  for Result := Low(FItems) to High(FItems) do
    if Comparer.Compare(FItems[Result], Value) = 0 then
      Exit;
  Result := -1;
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
  for Item in FItems do
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

constructor TBetterArray<T>.TEnumerator.Create(var AValue: TBetterArray<T>);
begin
  FValue := @AValue;
  FIndex := -1;
end;

function TBetterArray<T>.TEnumerator.GetCurrent: T;
begin
  Result := FValue^.FItems[FIndex];
end;

function TBetterArray<T>.TEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < High(FValue^.FItems);
  Inc(FIndex);
end;

end.
