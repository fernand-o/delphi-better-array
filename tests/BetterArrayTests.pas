unit BetterArrayTests;

interface

uses
  TestFramework,
  System.Generics.Collections,
  System.Generics.Defaults,
  BetterArray,
  DUnitX.Generics;

type
  TBetterArrayTests = class(TTestCase)
  private
    FSUT: TBetterArray<Integer>;
  public
    procedure SetUp; override;
  published
    procedure Add;
    procedure Clear;
    procedure Count;
    procedure Contains;
    procedure First;
    procedure FirstIndexOf;
    procedure Get;
    procedure Last;
    procedure LastIndexOf;
    procedure Join;
    procedure JoinQuoted;
    procedure Sort;
    procedure SortWithComparer;
    procedure Reverse;
  end;

implementation

procedure TBetterArrayTests.Add;
begin
  CheckEquals(6, FSUT.Count);
  FSUT.Add(0);
  CheckEquals(7, FSUT.Count);
  FSUT.Add([1, 2, 3]);
  CheckEquals(10, FSUT.Count);
end;

procedure TBetterArrayTests.Clear;
begin
  FSUT.Clear;
  CheckEquals(0, FSUT.Count);
end;

procedure TBetterArrayTests.Contains;
begin
  CheckTrue(FSUT.Contains(7));
  CheckFalse(FSUT.Contains(8));
end;

procedure TBetterArrayTests.Count;
begin
  CheckEquals(6, FSUT.Count);
end;

procedure TBetterArrayTests.First;
begin
  CheckEquals(13, FSUT.First);
end;

procedure TBetterArrayTests.FirstIndexOf;
begin
  CheckEquals(1, FSUT.FirstIndexOf(7));
  CheckEquals(0, FSUT.FirstIndexOf(13));
  CheckEquals(3, FSUT.FirstIndexOf(9));
end;

procedure TBetterArrayTests.Get;
begin
  CheckEquals(1, FSUT.Get(2));
  CheckEquals(9, FSUT.Get(3));
  CheckEquals(0, FSUT.Get(99));
end;

procedure TBetterArrayTests.LastIndexOf;
begin
  CheckEquals(1, FSUT.LastIndexOf(7));
  CheckEquals(0, FSUT.LastIndexOf(13));
  CheckEquals(4, FSUT.LastIndexOf(9));
end;

procedure TBetterArrayTests.Reverse;
begin
  FSUT.Reverse;
  CheckEquals(2, FSUT[0]);
  CheckEquals(9, FSUT[1]);
  CheckEquals(9, FSUT[2]);
  CheckEquals(1, FSUT[3]);
  CheckEquals(7, FSUT[4]);
  CheckEquals(13, FSUT[5]);
end;

procedure TBetterArrayTests.Join;
begin
  FSUT := [13, 7, 1992];
  CheckEquals('13/7/1992', FSUT.Join('/'));
  CheckEquals('13,7,1992', FSUT.Join);
  CheckEquals('1371992', FSUT.Join(''));
  CheckEquals('<13> <7> <1992>', FSUT.Join(' ', '<', '>'));
end;

procedure TBetterArrayTests.JoinQuoted;
begin
  FSUT := [13, 7, 1992];
  CheckEquals('''13'',''7'',''1992''', FSUT.JoinQuoted);
  CheckEquals('''13''->''7''->''1992''', FSUT.JoinQuoted('->'));
  CheckEquals('"13" "7" "1992"', FSUT.JoinQuoted(' ', '"'));
end;

procedure TBetterArrayTests.Last;
begin
  CheckEquals(2, FSUT.Last);
end;

procedure TBetterArrayTests.SetUp;
begin
  inherited;
  FSUT := [13, 7, 1, 9, 9, 2];
end;

procedure TBetterArrayTests.Sort;
begin
  FSUT.Sort;
  CheckEquals(1, FSUT[0]);
  CheckEquals(2, FSUT[1]);
  CheckEquals(7, FSUT[2]);
  CheckEquals(9, FSUT[3]);
  CheckEquals(9, FSUT[4]);
  CheckEquals(13, FSUT[5]);
end;

procedure TBetterArrayTests.SortWithComparer;
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
  FSUT.Sort(TDelegatedComparer<Integer>.Construct(EvenToOddNumbers));
  CheckEquals(1, FSUT[0]);
  CheckEquals(3, FSUT[1]);
  CheckEquals(5, FSUT[2]);
  CheckEquals(7, FSUT[3]);
  CheckEquals(2, FSUT[4]);
  CheckEquals(4, FSUT[5]);
  CheckEquals(6, FSUT[6]);
end;

initialization
  RegisterTest(TBetterArrayTests.Suite);

end.


