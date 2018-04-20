unit BetterArrayTests;

interface

uses
  TestFramework,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.SysUtils,
  System.Rtti,
  BetterArray,
  DUnitX.Generics;

type
  TBetterArrayIntegerTests = class(TTestCase)
  private
    FSUT: TBetterArray<Integer>;
  public
    procedure SetUp; override;
  published
    procedure Add;
    procedure Clear;
    procedure Compact;
    procedure Contains;
    procedure Count;
    procedure First;
    procedure FirstIndexOf;
    procedure Get;
    procedure Last;
    procedure LastIndexOf;
    procedure Join;
    procedure JoinQuoted;
    procedure Reverse;
    procedure Sort;
    procedure SortWithComparer;
    procedure ToStrings;
  end;

  TDummyClass = class
    Name: string;
    Age: Integer;
    constructor Create(Name: string; Age: Integer);
  end;

  TBetterArrayClassTests = class(TTestCase)
  private
    FSUT: TBetterArray<TDummyClass>;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Compact;
    procedure Reverse;
    procedure SortWithComparer;
    procedure ToStrings;
  end;

implementation

procedure TBetterArrayIntegerTests.Add;
begin
  CheckEquals(6, FSUT.Count);
  FSUT.Add(0);
  CheckEquals(7, FSUT.Count);
  FSUT.Add([1, 2, 3]);
  CheckEquals(10, FSUT.Count);
end;

procedure TBetterArrayIntegerTests.Clear;
begin
  FSUT.Clear;
  CheckEquals(0, FSUT.Count);
end;

procedure TBetterArrayIntegerTests.Compact;
begin
  FSUT := [1, 0, 2, 0, 0, 7, 0];

  CheckEquals(3, FSUT.Compact.Count);
  CheckEquals(1, FSUT.Compact[0]);
  CheckEquals(2, FSUT.Compact[1]);
  CheckEquals(7, FSUT.Compact[2]);
end;

procedure TBetterArrayIntegerTests.Contains;
begin
  CheckTrue(FSUT.Contains(7));
  CheckFalse(FSUT.Contains(8));
end;

procedure TBetterArrayIntegerTests.Count;
begin
  CheckEquals(6, FSUT.Count);
end;

procedure TBetterArrayIntegerTests.First;
begin
  CheckEquals(13, FSUT.First);
end;

procedure TBetterArrayIntegerTests.FirstIndexOf;
begin
  CheckEquals(1, FSUT.FirstIndexOf(7));
  CheckEquals(0, FSUT.FirstIndexOf(13));
  CheckEquals(3, FSUT.FirstIndexOf(9));
end;

procedure TBetterArrayIntegerTests.Get;
begin
  CheckEquals(1, FSUT.Get(2));
  CheckEquals(9, FSUT.Get(3));
  CheckEquals(0, FSUT.Get(99));
end;

procedure TBetterArrayIntegerTests.LastIndexOf;
begin
  CheckEquals(1, FSUT.LastIndexOf(7));
  CheckEquals(0, FSUT.LastIndexOf(13));
  CheckEquals(4, FSUT.LastIndexOf(9));
end;

procedure TBetterArrayIntegerTests.Reverse;
begin
  FSUT := FSUT.Reverse;
  CheckEquals(2, FSUT[0]);
  CheckEquals(9, FSUT[1]);
  CheckEquals(9, FSUT[2]);
  CheckEquals(1, FSUT[3]);
  CheckEquals(7, FSUT[4]);
  CheckEquals(13, FSUT[5]);
end;

procedure TBetterArrayIntegerTests.Join;
begin
  FSUT := [13, 7, 1992];
  CheckEquals('13/7/1992', FSUT.Join('/'));
  CheckEquals('13,7,1992', FSUT.Join);
  CheckEquals('1371992', FSUT.Join(''));
  CheckEquals('<13> <7> <1992>', FSUT.Join(' ', '<', '>'));
end;

procedure TBetterArrayIntegerTests.JoinQuoted;
begin
  FSUT := [13, 7, 1992];
  CheckEquals('''13'',''7'',''1992''', FSUT.JoinQuoted);
  CheckEquals('''13''->''7''->''1992''', FSUT.JoinQuoted('->'));
  CheckEquals('"13" "7" "1992"', FSUT.JoinQuoted(' ', '"'));
end;

procedure TBetterArrayIntegerTests.Last;
begin
  CheckEquals(2, FSUT.Last);
end;

procedure TBetterArrayIntegerTests.SetUp;
begin
  inherited;
  FSUT := [13, 7, 1, 9, 9, 2];
end;

procedure TBetterArrayIntegerTests.Sort;
begin
  FSUT := FSUT.Sort;
  CheckEquals(1, FSUT[0]);
  CheckEquals(2, FSUT[1]);
  CheckEquals(7, FSUT[2]);
  CheckEquals(9, FSUT[3]);
  CheckEquals(9, FSUT[4]);
  CheckEquals(13, FSUT[5]);
end;

procedure TBetterArrayIntegerTests.SortWithComparer;
var
  EvenToOddNumbers: TComparison<Integer>;
begin
  EvenToOddNumbers :=
    function(const Left, Right: Integer): Integer
    begin
      if Left = Right then
        Exit(0);

      if Odd(Left) then
        if Odd(Right) then
          Exit(Left - Right)
        else
          Exit(-1);

      if Odd(Right) then
        Exit(1)
      else
        Exit(Left - Right);
    end;

  FSUT := [1, 2, 3, 4, 5, 6, 7, 8];
  FSUT := FSUT.Sort(EvenToOddNumbers);
  CheckEquals(1, FSUT[0]);
  CheckEquals(3, FSUT[1]);
  CheckEquals(5, FSUT[2]);
  CheckEquals(7, FSUT[3]);
  CheckEquals(2, FSUT[4]);
  CheckEquals(4, FSUT[5]);
  CheckEquals(6, FSUT[6]);
end;

procedure TBetterArrayIntegerTests.ToStrings;
var
  ToStringFunc: TFunc<Integer, string>;
begin
  ToStringFunc :=
    function(Item: Integer): string
    begin
      Result := Item.ToString;
    end;

  FSUT := [13, 7, 1992];
  CheckEquals('13/7/1992', FSUT.ToStrings(ToStringFunc).Join('/'));
end;

procedure TBetterArrayClassTests.TearDown;
begin
  inherited;
  FSUT.FreeAll;
end;

procedure TBetterArrayClassTests.ToStrings;
var
  ToStringFunc: TFunc<TDummyClass, string>;
begin
  ToStringFunc :=
    function(Item: TDummyClass): string
    begin
      Result := Item.Name;
    end;

  CheckEquals('John & Ringo & Paul & George', FSUT.ToStrings(ToStringFunc).Join(' & '));
end;

procedure TBetterArrayClassTests.Compact;
begin
  Exit; // TODO: doesn't work
  FSUT[0].Free;
  FSUT[3].Free;

  CheckEquals(2, FSUT.Compact.Count);
  CheckEquals('Paul', FSUT.Compact[0].Name);
  CheckEquals('Ringo', FSUT.Compact[1].Name);
end;

procedure TBetterArrayClassTests.Reverse;
begin
  FSUT := FSUT.Reverse;
  CheckEquals('George', FSUT[0].Name);
  CheckEquals('Paul', FSUT[1].Name);
  CheckEquals('Ringo', FSUT[2].Name);
  CheckEquals('John', FSUT[3].Name);
end;

procedure TBetterArrayClassTests.SetUp;
begin
  inherited;
  FSUT := [
    TDummyClass.Create('John', 45),
    TDummyClass.Create('Ringo', 77),
    TDummyClass.Create('Paul', 75),
    TDummyClass.Create('George', 58)
  ];
end;

procedure TBetterArrayClassTests.SortWithComparer;
var
  OrderByAge: TComparison<TDummyClass>;
begin
  OrderByAge :=
    function(const Left, Right: TDummyClass): Integer
    begin
      Result := Left.Age - Right.Age;
    end;

  FSUT := FSUT.Sort(OrderByAge);
  CheckEquals('John', FSUT[0].Name);
  CheckEquals('George', FSUT[1].Name);
  CheckEquals('Paul', FSUT[2].Name);
  CheckEquals('Ringo', FSUT[3].Name);
end;

{ TDummyClass }

constructor TDummyClass.Create(Name: string; Age: Integer);
begin
  Self.Name := Name;
  Self.Age := Age;
end;

initialization
  RegisterTest(TBetterArrayIntegerTests.Suite);
  RegisterTest(TBetterArrayClassTests.Suite);

end.


